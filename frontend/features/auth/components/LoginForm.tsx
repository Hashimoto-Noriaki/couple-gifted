"use client";

import { useActionState } from "react";
import type { SignInState } from "../actions";

// 問い合わせ先は仮（doc/wireframes.md⑨）。決まるまではこの値を出し、本番運用（別リポジトリ）へ移る前に差し替える
const SUPPORT_CONTACT = "support@example.com";

const ERROR_MESSAGES = {
  // どちらの入力欄が誤っているかは区別しない（doc/use-cases.md「ログインする」）
  "invalid-credentials": "メールアドレスまたはパスワードが正しくありません",
  "account-suspended": "このアカウントは停止されています",
  unavailable: "ログインできませんでした。時間をおいてもう一度お試しください",
} as const;

type LoginFormProps = {
  // Server Actionを受け取る（Storybookでは差し替える）
  action: (state: SignInState, formData: FormData) => Promise<SignInState>;
  // ログイン後の戻り先。検証済みの値を渡す
  returnTo: string | null;
};

const initialState: SignInState = { error: null, email: "" };

export function LoginForm({ action, returnTo }: LoginFormProps) {
  const [state, formAction, pending] = useActionState(action, initialState);

  return (
    <form action={formAction} className="space-y-4">
      {/* メッセージは入力欄の上に1つだけ出し、文字だけを赤くする。入力欄の枠やラベルは赤くしない（doc/wireframes.md⑨） */}
      <div aria-live="polite">
        {state.error && (
          <div>
            <p className="text-red-600 text-sm">
              {ERROR_MESSAGES[state.error]}
            </p>
            {state.error === "account-suspended" && (
              <p className="mt-1 text-sm text-zinc-500">
                お問い合わせ：{SUPPORT_CONTACT}
              </p>
            )}
          </div>
        )}
      </div>
      {returnTo && <input type="hidden" name="return_to" value={returnTo} />}
      <div>
        <label htmlFor="email" className="block font-bold text-sm">
          メールアドレス
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          required
          // 失敗した後もメールアドレスは残す。パスワードは送信のたびに空に戻る
          defaultValue={state.email}
          className="mt-2 w-full rounded-lg border border-zinc-200 px-4 py-3"
        />
      </div>
      <div>
        <label htmlFor="password" className="block font-bold text-sm">
          パスワード
        </label>
        <input
          id="password"
          name="password"
          type="password"
          autoComplete="current-password"
          required
          className="mt-2 w-full rounded-lg border border-zinc-200 px-4 py-3"
        />
      </div>
      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-full bg-zinc-900 py-3 text-white disabled:bg-zinc-400"
      >
        {pending ? "ログイン中…" : "ログイン"}
      </button>
    </form>
  );
}
