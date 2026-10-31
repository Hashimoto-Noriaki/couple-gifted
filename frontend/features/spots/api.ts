import type { components, operations } from "@/shared/api-types";

type Spot = components["schemas"]["Spot"];
type SpotList = components["schemas"]["SpotList"];
type SpotDetail = components["schemas"]["SpotDetail"];
type AreaList = components["schemas"]["AreaList"];
type CategoryList = components["schemas"]["CategoryList"];
type ListSpotsQuery = NonNullable<
  operations["listSpots"]["parameters"]["query"]
>;

// Rails APIはServer Componentからだけ呼ぶため、NEXT_PUBLIC_は付けない（.claude/rules/frontend.md）
function apiBaseUrl(): string {
  const url = process.env.API_BASE_URL;
  if (!url) {
    throw new Error(
      "API_BASE_URL が設定されていません（frontend/README.md 参照）",
    );
  }
  return url;
}

async function getJson<T>(path: string): Promise<T> {
  const res = await fetch(`${apiBaseUrl()}${path}`);
  if (!res.ok) {
    throw new Error(`GET ${path} が失敗しました（${res.status}）`);
  }
  return res.json() as Promise<T>;
}

export function listSpots(query: ListSpotsQuery = {}): Promise<SpotList> {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined) params.set(key, String(value));
  }
  const qs = params.toString();
  return getJson<SpotList>(qs ? `/spots?${qs}` : "/spots");
}

// 「もっと見る」はURLのpagesで表すため、先頭からpagesページ分をnext_cursorで辿って取得する（lib/spotFilter.ts参照）
export async function listSpotPages(
  query: Omit<ListSpotsQuery, "cursor">,
  pages: number,
): Promise<{ spots: Spot[]; hasMore: boolean }> {
  const spots: Spot[] = [];
  let cursor: string | undefined;
  for (let i = 0; i < pages; i++) {
    const page = await listSpots({ ...query, cursor });
    spots.push(...page.spots);
    if (page.next_cursor === null) {
      return { spots, hasMore: false };
    }
    cursor = page.next_cursor;
  }
  return { spots, hasMore: true };
}

// 存在しないidならnullを返す（呼び出し側でnotFound()にする）
export async function getSpot(id: string): Promise<SpotDetail | null> {
  const path = `/spots/${encodeURIComponent(id)}`;
  const res = await fetch(`${apiBaseUrl()}${path}`);
  if (res.status === 404) {
    return null;
  }
  if (!res.ok) {
    throw new Error(`GET ${path} が失敗しました（${res.status}）`);
  }
  return res.json() as Promise<SpotDetail>;
}

export function listAreas(): Promise<AreaList> {
  return getJson<AreaList>("/areas");
}

export function listCategories(): Promise<CategoryList> {
  return getJson<CategoryList>("/categories");
}
