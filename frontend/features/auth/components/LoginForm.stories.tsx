import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { expect, userEvent, within } from "storybook/test";
import type { SignInState } from "../actions";
import { LoginForm } from "./LoginForm";

// Server Actionの代わりに、決まった結果を返すだけのaction
function returns(error: SignInState["error"]) {
  return async (_prev: SignInState, formData: FormData) => ({
    error,
    email: String(formData.get("email") ?? ""),
  });
}

const meta = {
  title: "auth/LoginForm",
  component: LoginForm,
  args: {
    action: returns(null),
    returnTo: "/spots/s1",
  },
} satisfies Meta<typeof LoginForm>;

export default meta;

type Story = StoryObj<typeof meta>;

async function submit(canvasElement: HTMLElement) {
  const canvas = within(canvasElement);
  await userEvent.type(
    canvas.getByLabelText("メールアドレス"),
    "hanako@example.com",
  );
  await userEvent.type(canvas.getByLabelText("パスワード"), "wrong-password");
  await userEvent.click(canvas.getByRole("button", { name: "ログイン" }));
  return canvas;
}

export const Default: Story = {};

// どちらの入力欄が誤っているかは示さない。メールアドレスだけ残る
export const InvalidCredentials: Story = {
  args: { action: returns("invalid-credentials") },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText(
        "メールアドレスまたはパスワードが正しくありません",
      ),
    ).toBeInTheDocument();
    await expect(canvas.getByLabelText("メールアドレス")).toHaveValue(
      "hanako@example.com",
    );
  },
};

export const AccountSuspended: Story = {
  args: { action: returns("account-suspended") },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText("このアカウントは停止されています"),
    ).toBeInTheDocument();
    await expect(canvas.getByText(/お問い合わせ：/)).toBeInTheDocument();
  },
};

export const Unavailable: Story = {
  args: { action: returns("unavailable") },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText(
        "ログインできませんでした。時間をおいてもう一度お試しください",
      ),
    ).toBeInTheDocument();
  },
};

// 送信中：応答が返らないactionで、ボタンが押せない状態を見る
export const Submitting: Story = {
  args: { action: () => new Promise<SignInState>(() => {}) },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByRole("button", { name: "ログイン中…" }),
    ).toBeDisabled();
  },
};
