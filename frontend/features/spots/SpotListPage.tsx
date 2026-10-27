import Link from "next/link";
import { listAreas, listCategories, listSpotPages } from "./api";
import { FilterSheet } from "./FilterSheet";
import { Header } from "./Header";
import { SpotCard } from "./SpotCard";
import {
  groupAreas,
  hasConditions,
  MAX_PAGES,
  parseSpotFilter,
  type RawSearchParams,
  spotDetailHref,
  spotListHref,
  toggleArea,
  toggleCategory,
} from "./spotFilter";

type SpotListPageProps = {
  searchParams: RawSearchParams;
};

export async function SpotListPage({ searchParams }: SpotListPageProps) {
  const filter = parseSpotFilter(searchParams);
  const [{ spots, hasMore }, { areas }, { categories }] = await Promise.all([
    listSpotPages(
      { area_id: filter.areaId, category_id: filter.categoryId },
      filter.pages,
    ),
    listAreas(),
    listCategories(),
  ]);
  // Spotはarea_id・category_idしか持たないため、名前はマスタから引く
  const areaNames = new Map(areas.map((area) => [area.id, area.name]));
  const categoryNames = new Map(categories.map((c) => [c.id, c.name]));
  const filtered = hasConditions(filter);
  const conditionNames = [
    filter.areaId && areaNames.get(filter.areaId),
    filter.categoryId && categoryNames.get(filter.categoryId),
  ].filter(Boolean);

  return (
    <div className="mx-auto w-full max-w-md px-4">
      <Header />
      {/* 件数は出さない。GET /spotsは総件数を返さないため（doc/wireframes.md①） */}
      <main className="py-6">
        <h1 className="font-bold text-xl">デートスポット</h1>
        <div className="mt-4">
          <FilterSheet
            areaGroups={groupAreas(areas).map(({ parent, children }) => ({
              id: parent.id,
              name: parent.name,
              options: children.map((area) => ({
                id: area.id,
                name: area.name,
                href: spotListHref(toggleArea(filter, area.id)),
                selected: area.id === filter.areaId,
              })),
            }))}
            categories={categories.map((category) => ({
              id: category.id,
              name: category.name,
              href: spotListHref(toggleCategory(filter, category.id)),
              selected: category.id === filter.categoryId,
            }))}
          />
        </div>
        {/* 「解除」「クリア」は使わない（doc/ubiquitous-language.md） */}
        {filtered && (
          <div className="mt-3 flex items-center justify-between text-sm">
            <p className="text-zinc-500">{conditionNames.join("・")}</p>
            <Link href="/spots" className="text-zinc-500 underline">
              すべて表示
            </Link>
          </div>
        )}
        {spots.length === 0 ? (
          <div className="mt-10 text-center">
            <p className="text-zinc-500">
              {filtered
                ? "条件に合うスポットはありません"
                : "スポットはまだありません"}
            </p>
            {/* 0件で行き止まりにしない（doc/wireframes.md①） */}
            {filtered && (
              <Link
                href="/spots"
                className="mt-4 inline-block rounded-full border border-zinc-200 px-6 py-3 text-sm"
              >
                すべて表示
              </Link>
            )}
          </div>
        ) : (
          <ul className="mt-4 space-y-4">
            {spots.map((spot) => (
              <li key={spot.id}>
                <SpotCard
                  href={spotDetailHref(spot.id, filter)}
                  name={spot.name}
                  areaName={areaNames.get(spot.area_id) ?? ""}
                  categoryName={categoryNames.get(spot.category_id) ?? ""}
                  averageRating={spot.average_rating}
                  reviewsCount={spot.reviews_count}
                />
              </li>
            ))}
          </ul>
        )}
        {/* 次のページが無ければボタンごと出さない（doc/wireframes.md①） */}
        {hasMore && filter.pages < MAX_PAGES && (
          <Link
            href={spotListHref({ ...filter, pages: filter.pages + 1 })}
            scroll={false}
            className="mt-6 block rounded-full border border-zinc-200 py-3 text-center text-sm"
          >
            もっと見る
          </Link>
        )}
      </main>
    </div>
  );
}
