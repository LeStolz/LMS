import { ReactNode, Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { getCourse } from "@/app/api/course/[courseId]/route";
import { Loader2 } from "lucide-react";
import { Banner } from "@/components/banner";
import { Button } from "@/components/ui/button";
import { searchCourseAnnouncement } from "@/app/api/course/course";
import { DataTable } from "./_components/data-table";
import { columns } from "./_components/column";

export default async function Component({
  params,
}: {
  params: { courseId: string };
}) {
  let data = await searchCourseAnnouncement({
    id: parseInt(params.courseId),
    offset: 0,
  });

  if (!data) {
    return redirect("/");
  }

  console.log(data);

  return (
    <>
      <div className="p-6">
        <DataTable columns={columns} data={data} />
      </div>
    </>
  );
}
