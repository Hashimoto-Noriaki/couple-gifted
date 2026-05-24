import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { Button } from "./Button";

describe("Button", () => {
  it("ラベルが表示される", () => {
    render(<Button label="テスト" />);
    expect(screen.getByRole("button", { name: "テスト" })).toBeInTheDocument();
  });
});
