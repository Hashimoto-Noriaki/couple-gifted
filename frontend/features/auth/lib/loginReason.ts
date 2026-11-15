// ログイン画面の最上部に出す説明文。割り込みで来たときは直前の操作を示す（doc/wireframes.md⑨）。
// URLの?reason=には、ここにあるキーだけを受け付ける（任意の文言を画面に出させない）
const LEADS = {
  save: "保存するにはログインが必要です",
  review: "レビューを投稿するにはログインが必要です",
} as const;

export type LoginReason = keyof typeof LEADS;

// ヘッダーの「ログイン」から来たとき（理由が無い・知らない理由のとき）の説明文
const DEFAULT_LEAD = "ログインしてください";

export function parseLoginReason(value: unknown): LoginReason | null {
  return typeof value === "string" && Object.hasOwn(LEADS, value)
    ? (value as LoginReason)
    : null;
}

export function loginLead(reason: LoginReason | null): string {
  return reason ? LEADS[reason] : DEFAULT_LEAD;
}
