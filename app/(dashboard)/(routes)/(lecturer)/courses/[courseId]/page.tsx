import { ReactNode, Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { getCourse } from "@/app/api/course/course";
import CourseForm from "./_components/courseForm";
import { Loader2 } from "lucide-react";

export default async function Component({
  params,
}: {
  params: { courseId: string };
}) {
  const user = authorize(["LT"]);

  const course = await getCourse({
    id: parseInt(params.courseId),
    withCategories: true,
  });

  if (!course) {
    return redirect("/courses");
  }

  return (
    <div className="container px-0 max-w-2xl">
      <h1 className="text-2xl font-bold pb-4">Update course</h1>
      <Suspense fallback={<Loader2 className="animate-spin" />}>
        <CourseForm course={course} />
      </Suspense>
    </div>
  );
}
