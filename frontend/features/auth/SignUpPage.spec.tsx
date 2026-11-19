import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { SignUpPage } from "./SignUpPage";

// Server Action（next/headers等）を読み込まないようにする
vi.mock("./actions", () => ({ signUpAction: vi.fn() }));

describe("SignUpPage", () => {
  it("ログイン画面から引き継いだ戻り先・理由を、ログイン画面への導線に引き継ぐ", () => {
    render(
      <SignUpPage searchParams={{ return_to: "/spots/s1", reason: "save" }} />,
    );

    expect(screen.getByRole("link", { name: "ログイン" })).toHaveAttribute(
      "href",
      "/login?return_to=%2Fspots%2Fs1&reason=save",
    );
    expect(screen.getByRole("link", { name: "戻る" })).toHaveAttribute(
      "href",
      "/spots/s1",
    );
  });

  it("戻り先が無ければ、ログイン画面への導線は素の/loginにし、戻るとスポット一覧へ", () => {
    render(<SignUpPage searchParams={{}} />);

    expect(screen.getByRole("link", { name: "ログイン" })).toHaveAttribute(
      "href",
      "/login",
    );
    expect(screen.getByRole("link", { name: "戻る" })).toHaveAttribute(
      "href",
      "/spots",
    );
  });

  it("サービス外の戻り先・知らない理由は引き継がない", () => {
    render(
      <SignUpPage
        searchParams={{ return_to: "//evil.example.com", reason: "hack" }}
      />,
    );

    expect(screen.getByRole("link", { name: "ログイン" })).toHaveAttribute(
      "href",
      "/login",
    );
  });

  it("規約に同意するまで登録ボタンを押せない", () => {
    render(<SignUpPage searchParams={{}} />);

    expect(screen.getByRole("button", { name: "登録する" })).toBeDisabled();
  });
});
