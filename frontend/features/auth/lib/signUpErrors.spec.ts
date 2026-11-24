import { describe, expect, it } from "vitest";
import { signUpErrorMessages } from "./signUpErrors";

describe("signUpErrorMessages", () => {
  it.each([
    ["email", "blank", "メールアドレスを入力してください"],
    ["email", "invalid", "メールアドレスの形式が正しくありません"],
    ["email", "taken", "このメールアドレスは既に使われています"],
    ["password", "blank", "パスワードを入力してください"],
    ["password", "too_short", "パスワードは8文字以上で入力してください"],
    ["password", "too_long", "パスワードが長すぎます"],
    ["nickname", "blank", "ニックネームを入力してください"],
    ["nickname", "too_long", "ニックネームは50文字以内で入力してください"],
  ] as const)("%s の %s は「%s」", (field, code, message) => {
    expect(signUpErrorMessages([{ field, code }])).toEqual({
      [field]: message,
    });
  });

  it("複数の項目のエラーを、項目ごとにまとめる", () => {
    expect(
      signUpErrorMessages([
        { field: "email", code: "taken" },
        { field: "nickname", code: "blank" },
      ]),
    ).toEqual({
      email: "このメールアドレスは既に使われています",
      nickname: "ニックネームを入力してください",
    });
  });

  it("1つの項目に複数のエラーがあれば、最初の1つだけを出す", () => {
    expect(
      signUpErrorMessages([
        { field: "password", code: "blank" },
        { field: "password", code: "too_short" },
      ]),
    ).toEqual({ password: "パスワードを入力してください" });
  });

  it("知らないコードは、項目ごとの汎用の文言にする", () => {
    expect(signUpErrorMessages([{ field: "email", code: "toString" }])).toEqual(
      { email: "メールアドレスを確認してください" },
    );
  });

  it("知らない項目は、入力欄に結びつけずフォーム全体の文言にする", () => {
    expect(
      signUpErrorMessages([{ field: "constructor", code: "blank" }]),
    ).toEqual({ form: "入力内容を確認してください" });
  });

  it("エラーが無ければ空", () => {
    expect(signUpErrorMessages([])).toEqual({});
  });
});
