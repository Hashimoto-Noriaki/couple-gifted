import Link from "next/link";
import { Header } from "@/shared/components/Header";
import { signUpAction } from "./actions";
import { SignUpForm } from "./components/SignUpForm";
import { parseLoginReason } from "./lib/loginReason";
import { DEFAULT_RETURN_TO, safeReturnTo } from "./lib/returnTo";

type SignUpPageProps = {
  searchParams: { [key: string]: string | string[] | undefined };
};

// 登録後は return_to があってもトップへ遷移する（.claude/rules/frontend.md「認証」）。
// return_to・reason を受け取るのは、「アカウントをお持ちの方」でログイン画面へ戻るときに引き継ぐためだけ
export function SignUpPage({ searchParams }: SignUpPageProps) {
  const returnTo = safeReturnTo(searchParams.return_to);
  const reason = parseLoginReason(searchParams.reason);

  const loginParams = new URLSearchParams();
  if (returnTo) loginParams.set("return_to", returnTo);
  if (reason) loginParams.set("reason", reason);
  const loginQuery = loginParams.toString();

  return (
    <div className="mx-auto w-full max-w-md px-4">
      {/* 「やっぱり登録しない」ときに元いた画面へ戻れるようにする（ログイン画面と同じ） */}
      <Header
        backHref={returnTo ?? DEFAULT_RETURN_TO}
        backLabel="戻る"
        showLoginLink={false}
      />
      <main className="py-6">
        <h1 className="font-bold text-xl">新規登録</h1>
        <div className="mt-6">
          <SignUpForm action={signUpAction} />
        </div>
        <section className="mt-10 border-zinc-200 border-t pt-6">
          <h2 className="font-bold text-sm">アカウントをお持ちの方</h2>
          <Link
            href={loginQuery ? `/login?${loginQuery}` : "/login"}
            className="mt-3 block rounded-full border border-zinc-200 py-3 text-center text-sm"
          >
            ログイン
          </Link>
        </section>
      </main>
    </div>
  );
}
