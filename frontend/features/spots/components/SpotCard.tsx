import Link from "next/link";
import { formatRating } from "../lib/formatRating";

type SpotCardProps = {
  // 一覧の絞り込み条件を引き継いだ詳細のURL（spotDetailHref）
  href: string;
  name: string;
  areaName: string;
  categoryName: string;
  averageRating: number | null;
  reviewsCount: number;
};

// カード全体をタップ領域にする（v0の「詳細を見る →」は採らない。doc/wireframes.md①）
export function SpotCard({
  href,
  name,
  areaName,
  categoryName,
  averageRating,
  reviewsCount,
}: SpotCardProps) {
  return (
    <Link
      href={href}
      className="block rounded-2xl border border-zinc-200 p-5 transition-colors hover:bg-zinc-50"
    >
      <h2 className="font-bold text-lg">{name}</h2>
      <p className="mt-2 text-sm text-zinc-500">
        {areaName} ／ {categoryName}
      </p>
      <p className="mt-2 text-sm text-zinc-500">
        {formatRating(averageRating, reviewsCount)}
      </p>
    </Link>
  );
}
