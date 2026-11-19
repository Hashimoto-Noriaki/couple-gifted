"use client";

import { useActionState, useState } from "react";
import type { SignUpState } from "../actions";
import { type SignUpField, signUpErrorMessages } from "../lib/signUpErrors";

type SignUpFormProps = {
  // Server Actionを受け取る（Storybookでは差し替える）
  action: (state: SignUpState, formData: FormData) => Promise<SignUpState>;
};

const initialState: SignUpState = {
  errors: [],
  unavailable: false,
  email: "",
  nickname: "",
};

const inputClass = "mt-2 w-full rounded-lg border border-zinc-200 px-4 py-3";

function FieldError({
  field,
  message,
}: {
  field: SignUpField;
  message: string | undefined;
}) {
  if (!message) return null;
  return (
    <p id={`${field}-error`} className="mt-1 text-red-600 text-sm">
      {message}
    </p>
  );
}

export function SignUpForm({ action }: SignUpFormProps) {
  const [state, formAction, pending] = useActionState(action, initialState);
  // メールアドレス・ニックネームは入力側で持つ（制御入力）。理由はLoginFormと同じで、
  // 送信後にフォームがリセットされても、応答待ちの間に直した内容を消さないため
  const [email, setEmail] = useState(initialState.email);
  const [nickname, setNickname] = useState(initialState.nickname);
  // 規約への同意はAPIに送らない。同意が無いと登録ボタンを押せないようにするだけ（doc/api/openapi.yaml /auth/sign_up）
  const [agreed, setAgreed] = useState(false);
  const messages = signUpErrorMessages(state.errors);

  return (
    <form action={formAction} className="space-y-4">
      <div aria-live="polite">
        {state.unavailable && (
          <p className="text-red-600 text-sm">
            登録できませんでした。時間をおいてもう一度お試しください
          </p>
        )}
        {messages.form && (
          <p className="text-red-600 text-sm">{messages.form}</p>
        )}
      </div>
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
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={messages.email ? true : undefined}
          aria-describedby={messages.email ? "email-error" : undefined}
          className={inputClass}
        />
        <FieldError field="email" message={messages.email} />
      </div>
      <div>
        <label htmlFor="password" className="block font-bold text-sm">
          パスワード
        </label>
        {/* 上限（UTF-8で72バイト）は出さず、超えたときのエラーで伝える（.claude/rules/frontend.md「認証」） */}
        <p id="password-hint" className="mt-1 text-sm text-zinc-500">
          8文字以上
        </p>
        <input
          id="password"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          // エラーで戻ったときパスワードは消す（送信のたびに空に戻る）
          aria-invalid={messages.password ? true : undefined}
          aria-describedby={
            messages.password ? "password-hint password-error" : "password-hint"
          }
          className={inputClass}
        />
        <FieldError field="password" message={messages.password} />
      </div>
      <div>
        <label htmlFor="nickname" className="block font-bold text-sm">
          ニックネーム
        </label>
        <input
          id="nickname"
          name="nickname"
          type="text"
          autoComplete="nickname"
          required
          value={nickname}
          onChange={(e) => setNickname(e.target.value)}
          aria-invalid={messages.nickname ? true : undefined}
          aria-describedby={messages.nickname ? "nickname-error" : undefined}
          className={inputClass}
        />
        <FieldError field="nickname" message={messages.nickname} />
      </div>
      {/* 本文が未作成のため、リンクは置かない（doc/requirements.md未決事項 #5）。本文ができたらリンクを足す */}
      <label className="flex items-start gap-2 text-sm">
        <input
          type="checkbox"
          checked={agreed}
          onChange={(e) => setAgreed(e.target.checked)}
          className="mt-1"
        />
        <span>利用規約・プライバシーポリシーに同意する</span>
      </label>
      <button
        type="submit"
        disabled={!agreed || pending}
        className="w-full rounded-full bg-zinc-900 py-3 text-white disabled:bg-zinc-400"
      >
        {pending ? "登録中…" : "登録する"}
      </button>
    </form>
  );
}
