import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { listAreas, listCategories, listSpotPages } from "./api";
import { SpotListPage } from "./SpotListPage";

vi.mock("./api");

const spot = {
  id: "s1",
  name: "代官山ガーデンカフェ",
  area_id: "daikanyama",
  category_id: "cafe",
  average_rating: 4.3,
  reviews_count: 12,
};

async function renderPage(searchParams: Record<string, string> = {}) {
  render(await SpotListPage({ searchParams }));
}

describe("SpotListPage", () => {
  beforeEach(() => {
    vi.mocked(listAreas).mockResolvedValue({
      areas: [
        { id: "shibuya", name: "渋谷エリア", parent_id: null, position: 1 },
        {
          id: "daikanyama",
          name: "代官山",
          parent_id: "shibuya",
          position: 1,
        },
      ],
    });
    vi.mocked(listCategories).mockResolvedValue({
      categories: [{ id: "cafe", name: "カフェ", position: 1 }],
    });
  });

  it("スポットのカードに、条件を引き継いだ詳細へのリンクを付ける", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({
      spots: [spot],
      hasMore: false,
    });

    await renderPage({ area_id: "daikanyama" });

    expect(
      screen.getByRole("link", { name: /代官山ガーデンカフェ/ }),
    ).toHaveAttribute("href", "/spots/s1?area_id=daikanyama");
    expect(listSpotPages).toHaveBeenCalledWith(
      { area_id: "daikanyama", category_id: undefined },
      1,
    );
  });

  it("絞り込み中は適用中の条件と「すべて表示」を出す", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({
      spots: [spot],
      hasMore: false,
    });

    await renderPage({ area_id: "daikanyama", category_id: "cafe" });

    expect(screen.getByText("代官山・カフェ")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "すべて表示" })).toHaveAttribute(
      "href",
      "/spots",
    );
  });

  it("絞り込んでいなければ「すべて表示」を出さない", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({
      spots: [spot],
      hasMore: false,
    });

    await renderPage();

    expect(
      screen.queryByRole("link", { name: "すべて表示" }),
    ).not.toBeInTheDocument();
  });

  it("絞り込んで0件なら、メッセージと「すべて表示」を出す", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({ spots: [], hasMore: false });

    await renderPage({ category_id: "cafe" });

    expect(
      screen.getByText("条件に合うスポットはありません"),
    ).toBeInTheDocument();
    expect(screen.getAllByRole("link", { name: "すべて表示" })).toHaveLength(2);
  });

  it("次のページがあれば、ページ数を1つ増やした「もっと見る」を出す", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({
      spots: [spot],
      hasMore: true,
    });

    await renderPage({ category_id: "cafe", pages: "2" });

    expect(screen.getByRole("link", { name: "もっと見る" })).toHaveAttribute(
      "href",
      "/spots?category_id=cafe&pages=3",
    );
  });

  it("次のページが無ければ「もっと見る」を出さない", async () => {
    vi.mocked(listSpotPages).mockResolvedValue({
      spots: [spot],
      hasMore: false,
    });

    await renderPage();

    expect(
      screen.queryByRole("link", { name: "もっと見る" }),
    ).not.toBeInTheDocument();
  });
});
