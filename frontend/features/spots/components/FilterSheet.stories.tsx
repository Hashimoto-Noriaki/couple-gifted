import type { Meta, StoryObj } from "@storybook/nextjs-vite";

import { FilterSheet } from "./FilterSheet";

const meta = {
  title: "spots/FilterSheet",
  component: FilterSheet,
  args: {
    areaGroups: [
      {
        id: "shibuya",
        name: "渋谷エリア",
        options: [
          {
            id: "daikanyama",
            name: "代官山",
            href: "/spots?area_id=daikanyama",
            selected: false,
          },
          {
            id: "ebisu",
            name: "恵比寿",
            href: "/spots?area_id=ebisu",
            selected: false,
          },
        ],
      },
    ],
    categories: [
      {
        id: "cafe",
        name: "カフェ",
        href: "/spots?category_id=cafe",
        selected: false,
      },
      {
        id: "restaurant",
        name: "レストラン",
        href: "/spots?category_id=restaurant",
        selected: false,
      },
      {
        id: "park",
        name: "公園",
        href: "/spots?category_id=park",
        selected: false,
      },
    ],
  },
} satisfies Meta<typeof FilterSheet>;

export default meta;

type Story = StoryObj<typeof meta>;

// 「絞り込み」を押すとシートが開く
export const Default: Story = {};

export const Selected: Story = {
  args: {
    areaGroups: [
      {
        id: "shibuya",
        name: "渋谷エリア",
        options: [
          {
            id: "daikanyama",
            name: "代官山",
            href: "/spots?category_id=cafe",
            selected: true,
          },
          {
            id: "ebisu",
            name: "恵比寿",
            href: "/spots?area_id=ebisu&category_id=cafe",
            selected: false,
          },
        ],
      },
    ],
    categories: [
      {
        id: "cafe",
        name: "カフェ",
        href: "/spots?area_id=daikanyama",
        selected: true,
      },
      {
        id: "restaurant",
        name: "レストラン",
        href: "/spots?area_id=daikanyama&category_id=restaurant",
        selected: false,
      },
    ],
  },
};
