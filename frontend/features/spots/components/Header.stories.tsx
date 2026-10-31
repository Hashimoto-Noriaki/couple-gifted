import type { Meta, StoryObj } from "@storybook/nextjs-vite";

import { Header } from "./Header";

const meta = {
  title: "spots/Header",
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
