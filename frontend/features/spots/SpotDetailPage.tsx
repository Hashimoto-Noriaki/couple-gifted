import { notFound } from "next/navigation";
import { getSpot, listAreas, listCategories } from "./api";
import { formatRating } from "./formatRating";
import { Header } from "./Header";
import {
  parseSpotFilter,
  type RawSearchParams,
  spotListHref,
} from "./spotFilter";

type SpotDetailPageProps = {
  id: string;
  // 一覧から引き継いだ絞り込み条件。「＜」の戻り先に使う（doc/wireframes.md②）
  searchParams: RawSearchParams;
};

export async function SpotDetailPage({
  id,
  searchParams,
}: SpotDetailPageProps) {
  const [spot, { areas }, { categories }] = await Promise.all([
    getSpot(id),
    listAreas(),
    listCategories(),
  ]);
  if (!spot) {
    notFound();
  }
  const areaName = areas.find((area) => area.id === spot.area_id)?.name ?? "";
  const categoryName =
    categories.find((c) => c.id === spot.category_id)?.name ?? "";

  return (
    <div className="mx-auto w-full max-w-md px-4">
      <Header backHref={spotListHref(parseSpotFilter(searchParams))} />
      <main className="py-6">
        <h1 className="font-bold text-2xl">{spot.name}</h1>
        <p className="mt-3 text-zinc-500">
          {formatRating(spot.average_rating, spot.reviews_count)}
        </p>
        <p className="mt-2 text-zinc-500">
          {areaName} ／ {categoryName}
        </p>
        <section className="mt-6 border-zinc-200 border-t pt-6">
          <h2 className="font-bold text-sm text-zinc-500">住所</h2>
          <p className="mt-2 break-words">{spot.address}</p>
        </section>
      </main>
    </div>
  );
}
