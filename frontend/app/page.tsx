import { redirect } from "next/navigation";

// トップは今のところスポット一覧を入口にする
export default function Page() {
  redirect("/spots");
}
