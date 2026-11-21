"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import {
  type AuthTokens,
  type SignInFailure,
  signIn,
  signUp,
  type ValidationError,
} from "./api";
import { DEFAULT_RETURN_TO, safeReturnTo } from "./lib/returnTo";

// "use server"のファイルからはasync関数しかexportできないため、定数はexportしない
const ACCESS_TOKEN_COOKIE = "access_token";
const REFRESH_TOKEN_COOKIE = "refresh_token";

// リフレッシュトークンの有効期限（doc/api/openapi.yaml AuthTokens.refresh_token）。
// APIのレスポンスには含まれないため、ここで合わせる
const REFRESH_TOKEN_MAX_AGE = 30 * 24 * 60 * 60;

export type SignInState = {
  // unavailable：APIが想定外の応答をした・届かなかった
  error: SignInFailure | "unavailable" | null;
  // 失敗した後もメールアドレスは入力欄に残す（パスワードは残さない）
  email: string;
};

export type SignUpState = {
  // 422の項目ごとのエラー。unavailableはAPIが想定外の応答をした・届かなかった
  errors: ValidationError[];
  unavailable: boolean;
  // 失敗した後もメールアドレス・ニックネームは入力欄に残す（パスワードは残さない）
  email: string;
  nickname: string;
};

// トークンはブラウザのJavaScriptから読めないhttpOnly Cookieに置く（.claude/rules/frontend.md「認証」）
async function saveTokens(tokens: AuthTokens) {
  const cookieStore = await cookies();
  const options = {
    httpOnly: true,
    // ローカル（http://localhost）では付けない。Safari等がSecureのCookieを保存しないため
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
  } as const;
  cookieStore.set(ACCESS_TOKEN_COOKIE, tokens.access_token, {
    ...options,
    maxAge: tokens.expires_in,
  });
  cookieStore.set(REFRESH_TOKEN_COOKIE, tokens.refresh_token, {
    ...options,
    maxAge: REFRESH_TOKEN_MAX_AGE,
  });
}

export async function signInAction(
  _prev: SignInState,
  formData: FormData,
): Promise<SignInState> {
  const email = String(formData.get("email") ?? "");
  const password = String(formData.get("password") ?? "");

  let result: Awaited<ReturnType<typeof signIn>>;
  try {
    result = await signIn({ email, password });
  } catch {
    return { error: "unavailable", email };
  }
  if (!result.ok) {
    return { error: result.reason, email };
  }

  await saveTokens(result.tokens);
  // redirectは例外を投げて遷移させるため、try/catchの外で呼ぶ（Next.jsのredirectのドキュメント）
  redirect(safeReturnTo(formData.get("return_to")) ?? DEFAULT_RETURN_TO);
}

export async function signUpAction(
  _prev: SignUpState,
  formData: FormData,
): Promise<SignUpState> {
  const email = String(formData.get("email") ?? "");
  const password = String(formData.get("password") ?? "");
  const nickname = String(formData.get("nickname") ?? "");

  let result: Awaited<ReturnType<typeof signUp>>;
  try {
    result = await signUp({ email, password, nickname });
  } catch {
    return { errors: [], unavailable: true, email, nickname };
  }
  if (!result.ok) {
    return { errors: result.errors, unavailable: false, email, nickname };
  }

  await saveTokens(result.tokens);
  // return_toがあってもトップへ（doc/use-cases.md「新規登録する」基本フロー7、.claude/rules/frontend.md「認証」）
  redirect(DEFAULT_RETURN_TO);
}
