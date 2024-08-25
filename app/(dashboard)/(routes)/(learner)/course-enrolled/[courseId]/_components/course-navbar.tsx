import { authorize } from "@/app/api/user/user";
import { CourseSection, Course, CourseCategories } from "@/types/course";
import { redirect } from "next/navigation";
import { CourseSidebarSection } from "./course-sidebar-section";

interface CourseSidebarProps {
  course: Course & CourseSection;
}

export const CourseNavbar = async ({ course }: CourseSidebarProps) => {
  const user = await authorize(["LN"]);
  if (!user) {
    return redirect("/");
  }

  // const isFree = course.sections.every((section) => section.isFree);

  return (
    <div className="p-4 border-b h-full flex items-center shadow-sm"></div>
  );
};