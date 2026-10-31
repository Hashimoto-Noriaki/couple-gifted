import type { components } from "@/shared/api-types";

type Area = components["schemas"]["Area"];

export type RawSearchParams = Record<string, string | string[] | undefined>;

// 一覧の状態はすべてURLのクエリで持つ（.claude/rules/frontend.md「データフェッチ」）。
// 詳細から「＜」で戻ったときに条件を残すため、詳細のURLにも同じクエリを引き継ぐ（doc/wireframes.md②）
export type SpotFilter = {
  areaId?: string;
  categoryId?: string;
  // 「もっと見る」で読み込んだページ数。cursorをURLに載せると、戻ったときに前のページが消えるため
  pages: number;
};

// pagesの数だけRails APIを順に呼ぶため、URLを書き換えて大量に呼ばせないよう上限を置く
export const MAX_PAGES = 10;

function first(value: string | string[] | undefined): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

export function parseSpotFilter(searchParams: RawSearchParams): SpotFilter {
  const pages = Number.parseInt(first(searchParams.pages) ?? "", 10);
  return {
    areaId: first(searchParams.area_id) || undefined,
    categoryId: first(searchParams.category_id) || undefined,
    pages: Number.isNaN(pages) ? 1 : Math.min(Math.max(pages, 1), MAX_PAGES),
  };
}

export function hasConditions(filter: SpotFilter): boolean {
  return Boolean(filter.areaId || filter.categoryId);
}

function toQueryString(filter: SpotFilter): string {
  const params = new URLSearchParams();
  if (filter.areaId) params.set("area_id", filter.areaId);
  if (filter.categoryId) params.set("category_id", filter.categoryId);
  if (filter.pages > 1) params.set("pages", String(filter.pages));
  return params.toString();
}

export function spotListHref(filter: SpotFilter): string {
  const qs = toQueryString(filter);
  return qs ? `/spots?${qs}` : "/spots";
}

export function spotDetailHref(id: string, filter: SpotFilter): string {
  const qs = toQueryString(filter);
  const path = `/spots/${encodeURIComponent(id)}`;
  return qs ? `${path}?${qs}` : path;
}

// 選択中のものをもう一度押すと外れる。条件が変わったら1ページ目から見せる（doc/wireframes.md①）
export function toggleArea(filter: SpotFilter, areaId: string): SpotFilter {
  return {
    ...filter,
    areaId: filter.areaId === areaId ? undefined : areaId,
    pages: 1,
  };
}

export function toggleCategory(
  filter: SpotFilter,
  categoryId: string,
): SpotFilter {
  return {
    ...filter,
    categoryId: filter.categoryId === categoryId ? undefined : categoryId,
    pages: 1,
  };
}

export type AreaGroup = {
  parent: Area;
  children: Area[];
};

// 親エリアを見出しに、子エリアを選択肢として並べる。親エリアは選べない
// （APIのarea_idは完全一致のため、親を選んでも子のスポットは含まれない。doc/wireframes.md①）。
// 子を持たない最上位エリアは選べる項目が無いため出さない
export function groupAreas(areas: Area[]): AreaGroup[] {
  return areas
    .filter((area) => area.parent_id === null)
    .map((parent) => ({
      parent,
      children: areas.filter((area) => area.parent_id === parent.id),
    }))
    .filter((group) => group.children.length > 0);
}
