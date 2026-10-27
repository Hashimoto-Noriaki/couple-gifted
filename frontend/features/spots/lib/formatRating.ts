// average_ratingがnullのときに「★0.0」等と出すと低評価と区別がつかないため、文言で出す（doc/wireframes.md①）
export function formatRating(
  averageRating: number | null,
  reviewsCount: number,
): string {
  if (averageRating === null) {
    return "評価はまだありません";
  }
  return `★${averageRating.toFixed(1)}（${reviewsCount}件）`;
}
