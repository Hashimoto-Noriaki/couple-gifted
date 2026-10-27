"use client";

import Link from "next/link";
import { useRef } from "react";

export type FilterOption = {
  id: string;
  name: string;
  // 押したときの遷移先。選択・選択解除のどちらになるかはServer Component側で決めて渡す
  href: string;
  selected: boolean;
};

type FilterSheetProps = {
  areaGroups: { id: string; name: string; options: FilterOption[] }[];
  categories: FilterOption[];
};

function OptionLink({ option }: { option: FilterOption }) {
  return (
    <Link
      href={option.href}
      scroll={false}
      aria-current={option.selected ? "true" : undefined}
      className={`block rounded-full border px-4 py-2 text-sm ${
        option.selected
          ? "border-zinc-900 bg-zinc-900 text-white"
          : "border-zinc-200"
      }`}
    >
      {option.name}
    </Link>
  );
}

// 画面下から開くシート。選ぶとすぐURLが変わって一覧が絞り込まれる。
// 同じページ内の遷移なのでシートは開いたまま残り、エリアとカテゴリを続けて選べる
export function FilterSheet({ areaGroups, categories }: FilterSheetProps) {
  const dialogRef = useRef<HTMLDialogElement>(null);

  return (
    <>
      <button
        type="button"
        onClick={() => dialogRef.current?.showModal()}
        className="rounded-full border border-zinc-200 px-4 py-2 text-sm"
      >
        絞り込み
      </button>
      <dialog
        ref={dialogRef}
        aria-label="絞り込み"
        className="mx-auto mt-auto mb-0 w-full max-w-md rounded-t-2xl bg-white p-5 backdrop:bg-black/30"
      >
        <div className="flex items-center justify-between">
          <h2 className="font-bold text-lg">絞り込み</h2>
          <button
            type="button"
            onClick={() => dialogRef.current?.close()}
            className="text-sm text-zinc-500"
          >
            閉じる
          </button>
        </div>
        <section className="mt-5">
          <h3 className="font-bold text-sm">エリア</h3>
          {areaGroups.map((group) => (
            <div key={group.id} className="mt-3">
              <p className="text-xs text-zinc-500">{group.name}</p>
              <ul className="mt-2 flex flex-wrap gap-2">
                {group.options.map((option) => (
                  <li key={option.id}>
                    <OptionLink option={option} />
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </section>
        <section className="mt-6">
          <h3 className="font-bold text-sm">カテゴリ</h3>
          <ul className="mt-3 flex flex-wrap gap-2">
            {categories.map((option) => (
              <li key={option.id}>
                <OptionLink option={option} />
              </li>
            ))}
          </ul>
        </section>
      </dialog>
    </>
  );
}
