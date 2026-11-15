import { describe, expect, it } from "vitest";
import { safeReturnTo } from "./returnTo";

describe("safeReturnTo", () => {
  it.each([
    ["/spots", "/spots"],
    [
      "/spots/s1?area_id=daikanyama#reviews",
      "/spots/s1?area_id=daikanyama#reviews",
    ],
    ["/", "/"],
  ])("サービス内のパス %s はそのまま受け付ける", (value, expected) => {
    expect(safeReturnTo(value)).toBe(expected);
  });

  it.each([
    ["絶対URL", "https://evil.example.com/spots"],
    ["プロトコル相対URL", "//evil.example.com"],
    ["バックスラッシュで別ホストになる", "/\\evil.example.com"],
    ["タブを挟んで別ホストになる", "/\t/evil.example.com"],
    ["javascript:スキーム", "javascript:alert(1)"],
    ["/始まりでない相対パス", "spots"],
    ["空文字", ""],
  ])("%s は受け付けない", (_label, value) => {
    expect(safeReturnTo(value)).toBeNull();
  });

  it.each([
    ["未指定", undefined],
    ["複数指定（配列）", ["/spots", "/spots/s1"]],
  ])("文字列でない値（%s）は受け付けない", (_label, value) => {
    expect(safeReturnTo(value)).toBeNull();
  });
});
