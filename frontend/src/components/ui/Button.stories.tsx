import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./Button";

const meta: Meta<typeof Button> = {
  title: "UI/Button",
  component: Button,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["primary", "secondary", "outline"],
    },
    size: { control: "select", options: ["sm", "md", "lg"] },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { label: "デートスポットを探す", variant: "primary" },
};

export const Secondary: Story = {
  args: { label: "キャンセル", variant: "secondary" },
};

export const Outline: Story = {
  args: { label: "もっと見る", variant: "outline" },
};

export const Disabled: Story = {
  args: { label: "送信", disabled: true },
};

export const Small: Story = {
  args: { label: "タグ", size: "sm" },
};
