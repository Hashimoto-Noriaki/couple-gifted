import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { LoginPage } from "./LoginPage";

// Server Action（next/headers等）を読み込まないようにする
vi.mock("./actions", () => ({ signInAction: vi.fn() }));

describe("LoginPage", () => {
  it("割り込みで来たときは、直前の操作と戻り先を引き継ぐ", () => {
    render(
      <LoginPage searchParams={{ return_to: "/spots/s1", reason: "save" }} />,
    );

    expect(
      screen.getByText("保存するにはログインが必要です"),
    ).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "戻る" })).toHaveAttribute(
      "href",
      "/spots/s1",
    );
    expect(screen.getByRole("link", { name: "新規登録" })).toHaveAttribute(
      "href",
      "/signup?return_to=%2Fspots%2Fs1&reason=save",
    );
    expect(document.querySelector('input[name="return_to"]')).toHaveValue(
      "/spots/s1",
    );
  });

  it("ヘッダーから来たときは、ログインを促す文言にし、戻るとスポット一覧へ", () => {
    render(<LoginPage searchParams={{}} />);

    expect(screen.getByText("ログインしてください")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "戻る" })).toHaveAttribute(
      "href",
      "/spots",
    );
    expect(screen.getByRole("link", { name: "新規登録" })).toHaveAttribute(
      "href",
      "/signup",
    );
    expect(document.querySelector('input[name="return_to"]')).toBeNull();
  });

  it("サービス外の戻り先は引き継がない", () => {
    render(
      <LoginPage searchParams={{ return_to: "https://evil.example.com" }} />,
    );

    expect(screen.getByRole("link", { name: "戻る" })).toHaveAttribute(
      "href",
      "/spots",
    );
    expect(document.querySelector('input[name="return_to"]')).toBeNull();
  });

  it("ヘッダーの右側に「ログイン」を出さない", () => {
    render(<LoginPage searchParams={{}} />);

    expect(
      screen.queryByRole("link", { name: "ログイン" }),
    ).not.toBeInTheDocument();
  });
});
