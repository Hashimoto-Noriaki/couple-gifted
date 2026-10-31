import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { listSpotPages } from "./api";

function spot(id: string) {
  return {
    id,
    name: id,
    area_id: "a1",
    category_id: "c1",
    average_rating: null,
    reviews_count: 0,
  };
}

function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), { status: 200 });
}

describe("listSpotPages", () => {
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

  it("next_cursorを辿って指定ページ数ぶんを連結する", async () => {
    fetchMock
      .mockResolvedValueOnce(
        jsonResponse({ spots: [spot("s1")], next_cursor: "cur1" }),
      )
      .mockResolvedValueOnce(
        jsonResponse({ spots: [spot("s2")], next_cursor: "cur2" }),
      );

    const result = await listSpotPages({ area_id: "a1" }, 2);

    expect(result.spots.map((s) => s.id)).toEqual(["s1", "s2"]);
    expect(result.hasMore).toBe(true);
    expect(fetchMock.mock.calls.map(([url]) => url)).toEqual([
      "http://api.test/spots?area_id=a1",
      "http://api.test/spots?area_id=a1&cursor=cur1",
    ]);
  });

  it("途中でnext_cursorがnullになったらそこで止め、次は無いとする", async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({ spots: [spot("s1")], next_cursor: null }),
    );

    const result = await listSpotPages({}, 3);

    expect(result).toEqual({ spots: [spot("s1")], hasMore: false });
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });
});
