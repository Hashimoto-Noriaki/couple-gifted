import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { signInAction } from "./actions";
import { signIn } from "./api";

vi.mock("next/headers");
vi.mock("next/navigation");
vi.mock("./api");

const tokens = {
  access_token: "access",
  refresh_token: "refresh",
  token_type: "Bearer" as const,
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

const initialState = { error: null, email: "" };

function form(fields: Record<string, string>) {
  const data = new FormData();
  for (const [key, value] of Object.entries(fields)) data.set(key, value);
  return data;
}

describe("signInAction", () => {
  const set = vi.fn();

  beforeEach(() => {
    vi.mocked(cookies).mockResolvedValue({ set } as never);
  });

  afterEach(() => {
    vi.resetAllMocks();
    vi.unstubAllEnvs();
  });

  describe("ログインに成功したとき", () => {
    beforeEach(() => {
      vi.mocked(signIn).mockResolvedValue({ ok: true, tokens });
    });

    it("2つのトークンをhttpOnly Cookieに、それぞれの有効期限で保存する", async () => {
      await signInAction(
        initialState,
        form({ email: "hanako@example.com", password: "password" }),
      );

      expect(signIn).toHaveBeenCalledWith({
        email: "hanako@example.com",
        password: "password",
      });
      const common = { httpOnly: true, sameSite: "lax", path: "/" };
      expect(set).toHaveBeenCalledWith(
        "access_token",
        "access",
        expect.objectContaining({ ...common, maxAge: 900 }),
      );
      expect(set).toHaveBeenCalledWith(
        "refresh_token",
        "refresh",
        expect.objectContaining({ ...common, maxAge: 30 * 24 * 60 * 60 }),
      );
    });

    it("本番ではSecureを付ける", async () => {
      vi.stubEnv("NODE_ENV", "production");

      await signInAction(
        initialState,
        form({ email: "hanako@example.com", password: "password" }),
      );

      for (const [, , options] of set.mock.calls) {
        expect(options.secure).toBe(true);
      }
    });

    it("戻り先があれば、そこへ戻す", async () => {
      await signInAction(
        initialState,
        form({ email: "a@example.com", password: "x", return_to: "/spots/s1" }),
      );

      expect(redirect).toHaveBeenCalledWith("/spots/s1");
    });

    it("戻り先が無ければ、トップ（スポット一覧）へ", async () => {
      await signInAction(
        initialState,
        form({ email: "a@example.com", password: "x" }),
      );

      expect(redirect).toHaveBeenCalledWith("/spots");
    });

    it("戻り先がサービス外なら、そこへは戻さずトップへ", async () => {
      await signInAction(
        initialState,
        form({
          email: "a@example.com",
          password: "x",
          return_to: "//evil.example.com",
        }),
      );

      expect(redirect).toHaveBeenCalledWith("/spots");
    });
  });

  it.each(["invalid-credentials", "account-suspended"] as const)(
    "%s なら、Cookieを保存せず理由とメールアドレスを返す",
    async (reason) => {
      vi.mocked(signIn).mockResolvedValue({ ok: false, reason });

      const state = await signInAction(
        initialState,
        form({ email: "hanako@example.com", password: "wrong" }),
      );

      expect(state).toEqual({ error: reason, email: "hanako@example.com" });
      expect(set).not.toHaveBeenCalled();
      expect(redirect).not.toHaveBeenCalled();
    },
  );

  it("APIが想定外の応答をしたら、unavailableを返す", async () => {
    vi.mocked(signIn).mockRejectedValue(new Error("500"));

    const state = await signInAction(
      initialState,
      form({ email: "hanako@example.com", password: "password" }),
    );

    expect(state).toEqual({
      error: "unavailable",
      email: "hanako@example.com",
    });
    expect(set).not.toHaveBeenCalled();
  });
});
