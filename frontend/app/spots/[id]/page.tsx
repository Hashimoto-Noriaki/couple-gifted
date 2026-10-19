import { SpotDetailPage } from "@/features/spots/SpotDetailPage";

export default async function Page({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <SpotDetailPage id={id} />;
}
