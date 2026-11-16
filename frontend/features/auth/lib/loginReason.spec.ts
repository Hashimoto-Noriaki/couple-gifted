import { describe, expect, it } from "vitest";
import { loginLead, parseLoginReason } from "./loginReason";

describe("parseLoginReason", () => {
  it("決まっている理由はそのまま受け付ける", () => {
    expect(parseLoginReason("save")).toBe("save");
  });

  it.each([
    ["知らない理由", "hack"],
    ["Objectのプロパティ名", "toString"],
    ["未指定", undefined],
    ["複数指定（配列）", ["save"]],
  ])("%s はnullにする", (_label, value) => {
    expect(parseLoginReason(value)).toBeNull();
  });
});

describe("loginLead", () => {
  it("理由があれば直前の操作を示す", () => {
    expect(loginLead("save")).toBe("保存するにはログインが必要です");
  });

  it("理由が無ければ（ヘッダーから来たとき）ログインを促すだけにする", () => {
    expect(loginLead(null)).toBe("ログインしてください");
  });
});
