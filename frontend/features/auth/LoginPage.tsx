import Link from "next/link";
import { Header } from "@/shared/components/Header";
import { signInAction } from "./actions";
import { LoginForm } from "./components/LoginForm";
import { loginLead, parseLoginReason } from "./lib/loginReason";
import { DEFAULT_RETURN_TO, safeReturnTo } from "./lib/returnTo";

type LoginPageProps = {
  searchParams: { [key: string]: string | string[] | undefined };
};

// ログイン画面は「入り口」ではなく「割り込み」（doc/screen-flow.md）。
// 割り込み元は /login?return_to=/spots/xxx&reason=save のように、戻り先と理由をURLで渡す
export function LoginPage({ searchParams }: LoginPageProps) {
  const returnTo = safeReturnTo(searchParams.return_to);
  const reason = parseLoginReason(searchParams.reason);

  // 新規登録へ進んでも、同じ戻り先・理由を引き継ぐ
  const signupParams = new URLSearchParams();
  if (returnTo) signupParams.set("return_to", returnTo);
  if (reason) signupParams.set("reason", reason);
  const signupQuery = signupParams.toString();

  return (
    <div className="mx-auto w-full max-w-md px-4">
      {/* 「やっぱりログインしない」ときに元いた画面へ戻れるようにする（doc/wireframes.md⑨） */}
      <Header
        backHref={returnTo ?? DEFAULT_RETURN_TO}
        backLabel="戻る"
        showLoginLink={false}
      />
      <main className="py-6">
        <p className="text-sm text-zinc-600">{loginLead(reason)}</p>
        <h1 className="mt-4 font-bold text-xl">ログイン</h1>
        <div className="mt-6">
          <LoginForm action={signInAction} returnTo={returnTo} />
        </div>
        <section className="mt-10 border-zinc-200 border-t pt-6">
          <h2 className="font-bold text-sm">アカウントをお持ちでない方</h2>
          <Link
            href={signupQuery ? `/signup?${signupQuery}` : "/signup"}
            className="mt-3 block rounded-full border border-zinc-200 py-3 text-center text-sm"
          >
            新規登録
          </Link>
        </section>
      </main>
    </div>
  );
}
