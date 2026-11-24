import { SignUpPage } from "@/features/auth/SignUpPage";

export default async function Page({
  searchParams,
}: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  return <SignUpPage searchParams={await searchParams} />;
}
