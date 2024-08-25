import { columns } from "./table/collumn-pending";
import { DataTable } from "./table/data-table";

export default async function Component({course }: {course: any[]}) {

  return (
    <>
      <div className="p-6">
        <DataTable columns={columns} data={course} type={course.length > 0 ? course[0].status : undefined} />
      </div>
    </>
  );
}