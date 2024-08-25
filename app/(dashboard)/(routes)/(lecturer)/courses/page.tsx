import { Button } from "@/components/ui/button";
import { DataTable } from "./_components/data-table";
import { columns } from "./_components/column";

import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { searchCourseByOwner } from "@/app/api/course/course";

export default async function Component() {
  let data;
  
  try{
    data = await searchCourseByOwner();
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