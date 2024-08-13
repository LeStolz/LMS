import { Button } from "@/components/ui/button";
import { DataTable } from "./_components/data-table";
import { columns } from "./_components/column";

import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { getCourseByOwner } from "@/app/api/course/course";

async function getData(): Promise<any[]> {
  // Fetch data from your API here.
  return [
    {
      id: "728ed52f",
      amount: 100,
      status: "pending",
      email: "m@example.com",
    },
    // ...
  ];
}

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
  let data;
  data = await getCourseByOwner({ ownerId: user.id });
  // if (user) {
  //   data = useQuery({
  //     queryKey: ["courses"],
  //     queryFn: async () => await getCourseByOwner({ ownerId: user.id }),
  //   });
  // }
  

  return (
    <>
      <div className="p-6">
        <DataTable columns={columns} data={data} />
      </div>
    </>
  );
}