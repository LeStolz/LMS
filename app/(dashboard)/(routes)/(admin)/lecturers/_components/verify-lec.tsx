import { selectLecturer } from "@/app/api/user/user";
import { columns } from "./table/collumn-pending";
import { DataTable } from "./table/data-table";
import { redirect } from "next/navigation";

export default async function Component() {
  let data;
  try {
    data = await selectLecturer({ status: "V" });
  } catch {
    console.log("error");
    return redirect("/");
  }
  return (
    <div className="p-6">
      <DataTable
        columns={columns}
        data={data}
        type={data.length > 0 ? data[0].status : undefined}
      />
    </div>
  );
}
