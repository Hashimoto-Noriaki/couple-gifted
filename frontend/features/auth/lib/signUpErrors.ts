import type { ValidationError } from "../api";

// 新規登録の422（errors[{field, code}]）を、項目ごとの文言にする。APIは文言を返さない（doc/api/openapi.yaml /auth/sign_up）
const MESSAGES = {
  email: {
    blank: "メールアドレスを入力してください",
    invalid: "メールアドレスの形式が正しくありません",
    // 停止済み・退会済みの会員と同じメールアドレスでも同じ文言にする（停止の事実を伝えない）
    taken: "このメールアドレスは既に使われています",
  },
  password: {
    blank: "パスワードを入力してください",
    too_short: "パスワードは8文字以上で入力してください",
    // 上限はUTF-8で72バイト。文字数では表せないため「長すぎる」とだけ伝える（.claude/rules/frontend.md「認証」）
    too_long: "パスワードが長すぎます",
  },
  nickname: {
    blank: "ニックネームを入力してください",
    too_long: "ニックネームは50文字以内で入力してください",
  },
} as const;

export type SignUpField = keyof typeof MESSAGES;

// 知らないコードが来たときの文言（APIに後からコードが増えた場合等）
const FALLBACK_MESSAGES: Record<SignUpField, string> = {
  email: "メールアドレスを確認してください",
  password: "パスワードを確認してください",
  nickname: "ニックネームを確認してください",
};

export type SignUpErrorMessages = Partial<Record<SignUpField, string>> & {
  // 入力欄に結びつかないエラー（知らない項目名）
  form?: string;
};

function isSignUpField(field: string): field is SignUpField {
  return Object.hasOwn(MESSAGES, field);
}

export function signUpErrorMessages(
  errors: ValidationError[],
): SignUpErrorMessages {
  const messages: SignUpErrorMessages = {};
  for (const { field, code } of errors) {
    if (!isSignUpField(field)) {
      messages.form ??= "入力内容を確認してください";
      continue;
    }
    // 1つの項目に複数のエラーがあっても、最初の1つだけを出す
    if (messages[field]) continue;
    const byCode: Record<string, string> = MESSAGES[field];
    messages[field] = Object.hasOwn(byCode, code)
      ? byCode[code]
      : FALLBACK_MESSAGES[field];
  }
  return messages;
}
