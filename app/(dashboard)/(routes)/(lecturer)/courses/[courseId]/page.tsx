import { ReactNode, Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { getCourse, getCourseOwner } from "@/app/api/course/course";
import CourseForm from "./_components/courseForm";
import { Loader2 } from "lucide-react";

export default async function Component({
  params,
}: {
  params: { courseId: string };
}) {
  const user = authorize(["LT"]);

  const course = await getCourseOwner({
    id: parseInt(params.courseId),
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
    <div className="container px-0 max-w-2xl">
      <div className="flex flex-col gap-y-2">
        <h1 className="text-2xl font-bold pb-4">Update course</h1>
        <span className="text-sm text-slate-300">Complete all fields {completeFields}</span>
      </div>
      <Suspense fallback={<Loader2 className="animate-spin" />}>
        <CourseForm course={course} />
      </Suspense>
    </div>
  );
}
