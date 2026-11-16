import { LoginPage } from "@/features/auth/LoginPage";

export default async function Page({
  searchParams,
}: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  return <LoginPage searchParams={await searchParams} />;
}
