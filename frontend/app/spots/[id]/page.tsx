import { SpotDetailPage } from "@/features/spots/SpotDetailPage";

export default async function Page({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const [{ id }, query] = await Promise.all([params, searchParams]);
  return <SpotDetailPage id={id} searchParams={query} />;
}
