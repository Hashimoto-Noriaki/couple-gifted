import { listAreas, listCategories, listSpots } from "./api";
import { Header } from "./Header";
import { SpotCard } from "./SpotCard";

export async function SpotListPage() {
  const [{ spots }, { areas }, { categories }] = await Promise.all([
    listSpots(),
    listAreas(),
    listCategories(),
  ]);
  // Spotはarea_id・category_idしか持たないため、名前はマスタから引く
  const areaNames = new Map(areas.map((area) => [area.id, area.name]));
  const categoryNames = new Map(categories.map((c) => [c.id, c.name]));

  return (
    <div className="mx-auto w-full max-w-md px-4">
      <Header />
      {/* 件数は出さない。GET /spotsは総件数を返さないため（doc/wireframes.md①） */}
      <main className="py-6">
        <h1 className="font-bold text-xl">デートスポット</h1>
        <ul className="mt-4 space-y-4">
          {spots.map((spot) => (
            <li key={spot.id}>
              <SpotCard
                id={spot.id}
                name={spot.name}
                areaName={areaNames.get(spot.area_id) ?? ""}
                categoryName={categoryNames.get(spot.category_id) ?? ""}
                averageRating={spot.average_rating}
                reviewsCount={spot.reviews_count}
              />
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}
