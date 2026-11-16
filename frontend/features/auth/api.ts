import type { components } from "@/shared/api-types";

type SignInRequest = components["schemas"]["SignInRequest"];
export type AuthTokens = components["schemas"]["AuthTokens"];

// ログインの失敗のうち、画面で出し分けるもの（doc/api/openapi.yaml /auth/sign_in）
export type SignInFailure = "invalid-credentials" | "account-suspended";

export type SignInResult =
  | { ok: true; tokens: AuthTokens }
  | { ok: false; reason: SignInFailure };

// Rails APIはServer Component・Server Actionからだけ呼ぶため、NEXT_PUBLIC_は付けない（.claude/rules/frontend.md）
function apiBaseUrl(): string {
  const url = process.env.API_BASE_URL;
  if (!url) {
    throw new Error(
      "API_BASE_URL が設定されていません（frontend/README.md 参照）",
    );
  }
  return url;
}

// 401・403は「入力した人に伝える結果」として返す。それ以外（5xx等）は想定外として例外にする
export async function signIn(body: SignInRequest): Promise<SignInResult> {
  const res = await fetch(`${apiBaseUrl()}/auth/sign_in`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });
  if (res.ok) {
    return { ok: true, tokens: (await res.json()) as AuthTokens };
  }
  // このエンドポイントでは、401はinvalid-credentials、403はaccount-suspendedだけを返す
  if (res.status === 401) {
    return { ok: false, reason: "invalid-credentials" };
  }
  if (res.status === 403) {
    return { ok: false, reason: "account-suspended" };
  }
  throw new Error(`POST /auth/sign_in が失敗しました（${res.status}）`);
}
