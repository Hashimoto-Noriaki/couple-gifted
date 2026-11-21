import type { components } from "@/shared/api-types";

type SignInRequest = components["schemas"]["SignInRequest"];
type SignUpRequest = components["schemas"]["SignUpRequest"];
// 422の errors[{field, code}]。文言はAPIが返さないため、画面側で組み立てる
export type ValidationError =
  components["schemas"]["ValidationProblem"]["errors"][number];
export type AuthTokens = components["schemas"]["AuthTokens"];

// ログインの失敗のうち、画面で出し分けるもの（doc/api/openapi.yaml /auth/sign_in）
export type SignInFailure = "invalid-credentials" | "account-suspended";

export type SignInResult =
  | { ok: true; tokens: AuthTokens }
  | { ok: false; reason: SignInFailure };

export type SignUpResult =
  | { ok: true; tokens: AuthTokens }
  | { ok: false; errors: ValidationError[] };

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

// 422は「入力した人に伝える結果」として返す。それ以外（5xx等）は想定外として例外にする
export async function signUp(body: SignUpRequest): Promise<SignUpResult> {
  const res = await fetch(`${apiBaseUrl()}/auth/sign_up`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });
  if (res.ok) {
    return { ok: true, tokens: (await res.json()) as AuthTokens };
  }
  if (res.status === 422) {
    const problem = (await res.json()) as Partial<
      components["schemas"]["ValidationProblem"]
    >;
    // 項目ごとのエラーが無い422は、どこを直せばよいか画面で伝えられないため、想定外として扱う
    // （APIの手前のプロキシ等が返した422や、契約と違う応答を画面の描画中の例外にしない）
    if (!Array.isArray(problem.errors) || problem.errors.length === 0) {
      throw new Error("POST /auth/sign_up の422に項目ごとのエラーがありません");
    }
    return { ok: false, errors: problem.errors };
  }
  throw new Error(`POST /auth/sign_up が失敗しました（${res.status}）`);
}
