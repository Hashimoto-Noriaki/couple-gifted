import type { Meta, StoryObj } from "@storybook/nextjs-vite";

import { SpotCard } from "./SpotCard";

const meta = {
  title: "spots/SpotCard",
  component: SpotCard,
  args: {
    href: "/spots/00000000-0000-0000-0000-000000000001",
    name: "茶房 ひより",
    areaName: "代官山",
    categoryName: "カフェ",
    averageRating: 4.2,
    reviewsCount: 12,
  },
} satisfies Meta<typeof SpotCard>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Rated: Story = {};

export const Unrated: Story = {
  args: {
    averageRating: null,
    reviewsCount: 0,
  },
};
