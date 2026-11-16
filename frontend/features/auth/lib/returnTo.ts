// 戻り先が無い・受け付けないときの行き先（トップ＝スポット検索・一覧。app/page.tsx参照）
export const DEFAULT_RETURN_TO = "/spots";

// 仮のオリジン。相対パスを解決して「別のオリジンに飛ばないか」を見るためだけに使う
const BASE = "http://return-to.invalid";

// ログイン後の戻り先（?return_to=）を検証する。サービス内のパスだけを受け付け、それ以外はnullを返す。
// オープンリダイレクトを防ぐため、「/」始まりであることに加えて、URLとして解決した結果が
// 同じオリジンに留まるかを確かめる。「//evil.com」「/\evil.com」「/\t/evil.com」のように、
// 文字列としては「/」始まりでもブラウザが別ホストとして解釈する書き方を弾くため
export function safeReturnTo(value: unknown): string | null {
  if (typeof value !== "string" || !value.startsWith("/")) {
    return null;
  }
  let url: URL;
  try {
    url = new URL(value, BASE);
  } catch {
    return null;
  }
  if (url.origin !== BASE) {
    return null;
  }
  // 「/a/..//evil.com」のように、..の正規化後に「//evil.com」になる書き方がある。
  // 返す文字列そのものをもう一度解決して、同じオリジンに留まるかを確かめる
  const normalized = `${url.pathname}${url.search}${url.hash}`;
  if (new URL(normalized, BASE).origin !== BASE) {
    return null;
  }
  return normalized;
}
