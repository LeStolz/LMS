import { Button } from "@/components/ui/button";
import { DataTable } from "./_components/data-table";
import { columns } from "./_components/column";

import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { getCourseByOwner } from "@/app/api/course/course";

export default async function Component() {
  let user;
  let data;

  try {
    user = await authorize(["LN", "LT", "AD"], true);
  } catch {
    return redirect("/");
  }

  if (!user) {
    return redirect("/");
  }
  
  try{
    data = await getCourseByOwner({ ownerId: user.id });
  }
  catch{
    return redirect("/");
  }

  return (
    <>
      <div className="p-6">
        <DataTable columns={columns} data={data} />
      </div>
    </>
  );
}