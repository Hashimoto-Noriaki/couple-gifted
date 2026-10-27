import { describe, expect, it } from "vitest";
import {
  groupAreas,
  hasConditions,
  MAX_PAGES,
  parseSpotFilter,
  spotDetailHref,
  spotListHref,
  toggleArea,
  toggleCategory,
} from "./spotFilter";

describe("parseSpotFilter", () => {
  it("クエリが無ければ条件なし・1ページ目", () => {
    expect(parseSpotFilter({})).toEqual({
      areaId: undefined,
      categoryId: undefined,
      pages: 1,
    });
  });

  it("area_id・category_id・pagesを読み取る", () => {
    expect(
      parseSpotFilter({ area_id: "a1", category_id: "c1", pages: "3" }),
    ).toEqual({ areaId: "a1", categoryId: "c1", pages: 3 });
  });

  it("同じキーが複数あれば先頭を使う", () => {
    expect(parseSpotFilter({ area_id: ["a1", "a2"] }).areaId).toBe("a1");
  });

  it("空文字の条件は無いものとして扱う", () => {
    expect(parseSpotFilter({ area_id: "", category_id: "" })).toMatchObject({
      areaId: undefined,
      categoryId: undefined,
    });
  });

  it("数値でないpagesは1ページ目にする", () => {
    expect(parseSpotFilter({ pages: "abc" }).pages).toBe(1);
  });

  it("1未満のpagesは1に、上限を超えるpagesはMAX_PAGESに丸める", () => {
    expect(parseSpotFilter({ pages: "0" }).pages).toBe(1);
    expect(parseSpotFilter({ pages: "1000" }).pages).toBe(MAX_PAGES);
  });
});

describe("hasConditions", () => {
  it("エリアかカテゴリのどちらかがあれば絞り込み中", () => {
    expect(hasConditions({ areaId: "a1", pages: 1 })).toBe(true);
    expect(hasConditions({ categoryId: "c1", pages: 1 })).toBe(true);
  });

  it("ページ数だけでは絞り込み中にしない", () => {
    expect(hasConditions({ pages: 3 })).toBe(false);
  });
});

describe("spotListHref", () => {
  it("条件が無く1ページ目ならクエリを付けない", () => {
    expect(spotListHref({ pages: 1 })).toBe("/spots");
  });

  it("条件とページ数をクエリに載せる", () => {
    expect(spotListHref({ areaId: "a1", categoryId: "c1", pages: 2 })).toBe(
      "/spots?area_id=a1&category_id=c1&pages=2",
    );
  });
});

describe("spotDetailHref", () => {
  it("一覧の条件を詳細のURLに引き継ぐ", () => {
    expect(spotDetailHref("s1", { areaId: "a1", pages: 2 })).toBe(
      "/spots/s1?area_id=a1&pages=2",
    );
  });

  it("条件が無ければクエリを付けない", () => {
    expect(spotDetailHref("s1", { pages: 1 })).toBe("/spots/s1");
  });
});

describe("toggleArea / toggleCategory", () => {
  it("未選択のものを押すと選択し、1ページ目に戻す", () => {
    expect(toggleArea({ categoryId: "c1", pages: 3 }, "a1")).toEqual({
      areaId: "a1",
      categoryId: "c1",
      pages: 1,
    });
    expect(toggleCategory({ pages: 3 }, "c1")).toEqual({
      categoryId: "c1",
      pages: 1,
    });
  });

  it("選択中のものをもう一度押すと外れる", () => {
    expect(toggleArea({ areaId: "a1", pages: 1 }, "a1").areaId).toBeUndefined();
    expect(
      toggleCategory({ categoryId: "c1", pages: 1 }, "c1").categoryId,
    ).toBeUndefined();
  });

  it("別のものを押すと置き換わる（1つずつしか選べない）", () => {
    expect(toggleArea({ areaId: "a1", pages: 1 }, "a2").areaId).toBe("a2");
  });
});

describe("groupAreas", () => {
  const shibuya = {
    id: "p1",
    name: "渋谷エリア",
    parent_id: null,
    position: 1,
  };
  const daikanyama = { id: "c1", name: "代官山", parent_id: "p1", position: 1 };
  const ebisu = { id: "c2", name: "恵比寿", parent_id: "p1", position: 2 };

  it("親エリアごとに子エリアをまとめる", () => {
    expect(groupAreas([shibuya, daikanyama, ebisu])).toEqual([
      { parent: shibuya, children: [daikanyama, ebisu] },
    ]);
  });

  it("子を持たない最上位エリアは出さない", () => {
    const lonely = {
      id: "p2",
      name: "新宿エリア",
      parent_id: null,
      position: 2,
    };
    expect(groupAreas([shibuya, daikanyama, lonely])).toEqual([
      { parent: shibuya, children: [daikanyama] },
    ]);
  });
});
