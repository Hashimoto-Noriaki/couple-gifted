import type { Meta, StoryObj } from "@storybook/nextjs-vite";

import { Header } from "./Header";

const meta = {
  title: "shared/Header",
  component: Header,
} satisfies Meta<typeof Header>;

export default meta;

type Story = StoryObj<typeof meta>;

export const List: Story = {};

export const WithBack: Story = {
  args: {
    backHref: "/spots",
  },
};

// ログイン画面：戻るボタンだけで、右側の「ログイン」は出さない
export const Login: Story = {
  args: {
    backHref: "/spots/s1",
    backLabel: "戻る",
    showLoginLink: false,
  },
};
