import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { Button } from "./Button";

describe("Button", () => {
  it("渡した文字列を表示する", () => {
    render(<Button>押す</Button>);
    expect(screen.getByText("押す")).toBeInTheDocument();
  });
});
