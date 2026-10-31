import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";

// Vitestのglobalsを有効にしていないため、Testing Libraryの自動cleanupが効かない。
// テストごとに描画したDOMを片付けないと、前のテストの要素が次のテストに残る
afterEach(() => {
  cleanup();
});
