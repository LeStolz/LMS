import { Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { Loader2 } from "lucide-react";
import UserForm from "./_components/userForm";

export default async function Component() {
  let user;

  try {
    user = await authorize(["LN", "LT", "AD"], true);
  } catch {
    return redirect("/");
  }

  if (!user) {
    return redirect("/");
  }

  return (
    <div className="container px-0 max-w-2xl">
      <h1 className="text-2xl font-bold pb-4">Update profile</h1>
      <Suspense fallback={<Loader2 className="animate-spin" />}>
        <UserForm user={user} />
      </Suspense>
    </div>
  );
}
