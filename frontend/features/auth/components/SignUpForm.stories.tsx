import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { expect, userEvent, within } from "storybook/test";
import type { SignUpState } from "../actions";
import { SignUpForm } from "./SignUpForm";

// Server Actionの代わりに、決まった結果を返すだけのaction
function returns(
  errors: SignUpState["errors"],
  unavailable = false,
): (prev: SignUpState, formData: FormData) => Promise<SignUpState> {
  return async (_prev, formData) => ({
    errors,
    unavailable,
    email: String(formData.get("email") ?? ""),
    nickname: String(formData.get("nickname") ?? ""),
  });
}

const meta = {
  title: "auth/SignUpForm",
  component: SignUpForm,
  args: { action: returns([]) },
} satisfies Meta<typeof SignUpForm>;

export default meta;

type Story = StoryObj<typeof meta>;

async function submit(canvasElement: HTMLElement) {
  const canvas = within(canvasElement);
  await userEvent.type(
    canvas.getByLabelText("メールアドレス"),
    "hanako@example.com",
  );
  await userEvent.type(canvas.getByLabelText("パスワード"), "password");
  await userEvent.type(canvas.getByLabelText("ニックネーム"), "はなこ");
  await userEvent.click(
    canvas.getByLabelText("利用規約・プライバシーポリシーに同意する"),
  );
  await userEvent.click(canvas.getByRole("button", { name: "登録する" }));
  return canvas;
}

// 規約に同意するまで登録ボタンは押せない
export const Default: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    const button = canvas.getByRole("button", { name: "登録する" });
    await expect(button).toBeDisabled();
    await userEvent.click(
      canvas.getByLabelText("利用規約・プライバシーポリシーに同意する"),
    );
    await expect(button).toBeEnabled();
  },
};

// 停止済み・退会済みの会員と同じメールアドレスでも、この表示になる
export const EmailTaken: Story = {
  args: { action: returns([{ field: "email", code: "taken" }]) },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText("このメールアドレスは既に使われています"),
    ).toBeInTheDocument();
    // メールアドレス・ニックネームは残し、パスワードは消す
    await expect(canvas.getByLabelText("メールアドレス")).toHaveValue(
      "hanako@example.com",
    );
    await expect(canvas.getByLabelText("ニックネーム")).toHaveValue("はなこ");
    await expect(canvas.getByLabelText("パスワード")).toHaveValue("");
    // フォームのリセットで外れた同意に合わせて、登録ボタンも押せなくなる
    await expect(
      canvas.getByLabelText("利用規約・プライバシーポリシーに同意する"),
    ).not.toBeChecked();
    await expect(
      canvas.getByRole("button", { name: "登録する" }),
    ).toBeDisabled();
  },
};

export const PasswordTooShort: Story = {
  args: { action: returns([{ field: "password", code: "too_short" }]) },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText("パスワードは8文字以上で入力してください"),
    ).toBeInTheDocument();
  },
};

export const MultipleErrors: Story = {
  args: {
    action: returns([
      { field: "email", code: "invalid" },
      { field: "password", code: "too_long" },
      { field: "nickname", code: "too_long" },
    ]),
  },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText("メールアドレスの形式が正しくありません"),
    ).toBeInTheDocument();
    await expect(
      canvas.getByText("パスワードが長すぎます"),
    ).toBeInTheDocument();
    await expect(
      canvas.getByText("ニックネームは50文字以内で入力してください"),
    ).toBeInTheDocument();
  },
};

export const Unavailable: Story = {
  args: { action: returns([], true) },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByText(
        "登録できませんでした。時間をおいてもう一度お試しください",
      ),
    ).toBeInTheDocument();
  },
};

// 送信中：応答が返らないactionで、ボタンが押せない状態を見る
export const Submitting: Story = {
  args: { action: () => new Promise<SignUpState>(() => {}) },
  play: async ({ canvasElement }) => {
    const canvas = await submit(canvasElement);
    await expect(
      await canvas.findByRole("button", { name: "登録中…" }),
    ).toBeDisabled();
  },
};
