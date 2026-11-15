import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { signIn } from "./api";

const tokens = {
  access_token: "access",
  refresh_token: "refresh",
  token_type: "Bearer",
  expires_in: 900,
  user: {
    id: "00000000-0000-0000-0000-000000000001",
    email: "hanako@example.com",
    nickname: "はなこ",
    age_band: null,
    area_id: null,
    has_children: false,
    relationship_stage: null,
  },
};

function problem(status: number) {
  return new Response(
    JSON.stringify({ type: "about:blank", title: "", status }),
    {
      status,
      headers: { "Content-Type": "application/problem+json" },
    },
  );
}

describe("signIn", () => {
  const fetchMock = vi.fn<typeof fetch>();

  beforeEach(() => {
    vi.stubEnv("API_BASE_URL", "http://api.test");
    vi.stubGlobal("fetch", fetchMock);
  });

  afterEach(() => {
    fetchMock.mockReset();
    vi.unstubAllEnvs();
    vi.unstubAllGlobals();
  });

  it("メールアドレスとパスワードをJSONでPOSTし、トークンを返す", async () => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(tokens), { status: 200 }),
    );

    const result = await signIn({
      email: "hanako@example.com",
      password: "password",
    });

    expect(result).toEqual({ ok: true, tokens });
    const [url, init] = fetchMock.mock.calls[0];
    expect(url).toBe("http://api.test/auth/sign_in");
    expect(init?.method).toBe("POST");
    expect(JSON.parse(String(init?.body))).toEqual({
      email: "hanako@example.com",
      password: "password",
    });
  });

  it("401ならinvalid-credentialsとして返す", async () => {
    fetchMock.mockResolvedValueOnce(problem(401));

    expect(await signIn({ email: "a@example.com", password: "x" })).toEqual({
      ok: false,
      reason: "invalid-credentials",
    });
  });

  it("403ならaccount-suspendedとして返す", async () => {
    fetchMock.mockResolvedValueOnce(problem(403));

    expect(await signIn({ email: "a@example.com", password: "x" })).toEqual({
      ok: false,
      reason: "account-suspended",
    });
  });

  it("想定外のステータスは例外にする", async () => {
    fetchMock.mockResolvedValueOnce(problem(500));

    await expect(
      signIn({ email: "a@example.com", password: "x" }),
    ).rejects.toThrow("500");
  });
});
