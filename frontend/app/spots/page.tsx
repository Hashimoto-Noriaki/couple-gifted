import { SpotListPage } from "@/features/spots/SpotListPage";

export default async function Page({
  searchParams,
}: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  return <SpotListPage searchParams={await searchParams} />;
}
