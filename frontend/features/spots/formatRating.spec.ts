import { describe, expect, it } from "vitest";
import { formatRating } from "./formatRating";

describe("formatRating", () => {
  it("評価があれば小数1桁と件数を表示する", () => {
    expect(formatRating(4.2, 12)).toBe("★4.2（12件）");
  });

  it("整数の評価も小数1桁で表示する", () => {
    expect(formatRating(4, 3)).toBe("★4.0（3件）");
  });

  it("評価が無ければ「評価はまだありません」を表示する", () => {
    expect(formatRating(null, 0)).toBe("評価はまだありません");
  });
});
