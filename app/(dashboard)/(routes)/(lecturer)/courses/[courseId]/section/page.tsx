import { ReactNode, Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { getCourse } from "@/app/api/course/[courseId]/route";
import { Loader2 } from "lucide-react";
import SectionForm from "./_components/sectionForm";
import { Banner } from "@/components/banner";

export default async function Component({
  params,
}: {
  params: { courseId: string };
}) {
  const course = await getCourse({
    id: parseInt(params.courseId),
    withCategories: true,
    withSections: true,
    withReviews: true,
  });

  if (!course) {
    return redirect("/courses");
  }
  const requestFields = Object.values(course);
  const totalFields = requestFields.length;
  const completedFields = requestFields.filter((field) => field).length;
  const progress = Math.round((completedFields / totalFields) * 100);
  const completeFields = `${completedFields}/${totalFields}`;

  return (
    <>
      {course.status === "C" && (
        <Banner
          variant="warning"
          label="This couse is created but not published yet"
        />
      )}
      {course.status === "P" && (
        <Banner
          variant="default"
          label="This course is published and in pending list"
        />
      )}
      {course.status === "R" && (
        <Banner
          variant="danger"
          label="This course is rejected published and active"
        />
      )}

      {course.status === "V" && (
        <Banner variant="success" label="This course is published" />
      )}
      <div className="container px-0 max-w-2xl">
        <div className="flex flex-col gap-y-2">
          <h1 className="text-2xl font-bold pb-4 pt-4">Update course</h1>
          <span className="text-sm text-slate-300">
            Complete all fields {completeFields}
          </span>
        </div>
        <Suspense fallback={<Loader2 className="animate-spin" />}>
          <SectionForm course={course} />
        </Suspense>
      </div>
    </>
  );
}
