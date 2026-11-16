import Link from "next/link";

type HeaderProps = {
  // 渡したときだけ左端に「＜」を出す（詳細画面・ログイン画面。doc/wireframes.md②⑨）
  backHref?: string;
  // 「＜」の読み上げ用の名前
  backLabel?: string;
  // ログイン画面では右側に何も置かない（doc/wireframes.md⑨）
  showLoginLink?: boolean;
};

export function Header({
  backHref,
  backLabel = "一覧に戻る",
  showLoginLink = true,
}: HeaderProps) {
  return (
    <header className="flex items-center justify-between border-zinc-200 border-b py-5">
      <div className="flex items-center gap-4">
        {backHref && (
          <Link href={backHref} aria-label={backLabel} className="text-2xl">
            ＜
          </Link>
        )}
        <span className="font-bold text-xl">CoupleGifted</span>
      </div>
      {/* ログインしなくても使える画面なので、誘導は目立たせない（doc/wireframes.md①） */}
      {showLoginLink && (
        <Link href="/login" className="text-sm text-zinc-500">
          ログイン
        </Link>
      )}
    </header>
  );
}
