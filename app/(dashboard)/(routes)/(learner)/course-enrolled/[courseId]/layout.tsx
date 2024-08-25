import { getCourse } from "@/app/api/course/[courseId]/route";
import { authorize } from "@/app/api/user/user";
import exp from "constants";
import { redirect } from "next/navigation";
import { CourseSidebar } from "./_components/course-sidebar";
const CourseLayout = async ({
  children,
  params,
}: {
  children: React.ReactNode;
  params: { courseId: string };
}) => {
  const user = await authorize(["LN"]);
  if (!user) {
    return redirect("/");
  }

  const course = await getCourse({
    id: parseInt(params.courseId),
    withCategories: true,
    withSections: true,
    withReviews: true,
  });

  if (!course) {
    return redirect("/");
  }
  return (
    <div className="h-full">
        <div className="h-[80px] md:pl-80 fixed inset-y-0 w-full z-50">
            {/* <CourseNavbar course={course} /> */}
        </div>
      <div className="hidden md:flex h-full w-80 flex-col fixed inset-y-0 z-50">
        <CourseSidebar course={course} />
      </div>
      <main className="md:pl-80 h-full">{children}</main>
    </div>
  );
};

export default CourseLayout;
