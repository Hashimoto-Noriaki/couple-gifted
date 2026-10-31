import Link from "next/link";

type HeaderProps = {
  // 渡したときだけ左端に「＜」を出す（詳細画面。doc/wireframes.md②）
  backHref?: string;
};

export function Header({ backHref }: HeaderProps) {
  return (
    <header className="flex items-center justify-between border-zinc-200 border-b py-5">
      <div className="flex items-center gap-4">
        {backHref && (
          <Link href={backHref} aria-label="一覧に戻る" className="text-2xl">
            ＜
          </Link>
        )}
        <span className="font-bold text-xl">CoupleGifted</span>
      </div>
      {/* ログインしなくても使える画面なので、誘導は目立たせない（doc/wireframes.md①） */}
      <Link href="/login" className="text-sm text-zinc-500">
        ログイン
      </Link>
    </header>
  );
}
