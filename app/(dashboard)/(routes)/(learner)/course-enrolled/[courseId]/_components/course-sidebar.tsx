import { authorize } from "@/app/api/user/user";
import { CourseSection, Course, CourseCategories } from "@/types/course";
import { redirect, usePathname, useRouter } from "next/navigation";
import { CourseSidebarSection } from "./course-sidebar-section";
import { getSection } from "@/app/api/course/[courseId]/[sectionId]/route";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { BellRing, Icon } from "lucide-react";
import { CourseSidebarAnnouncement } from "./course-announcement";

interface CourseSidebarProps {
  course: Course & CourseSection;
}

export const CourseSidebar = async ({ course }: CourseSidebarProps) => {
  const user = await authorize(["LN"]);
  if (!user) {
    return redirect("/");
  }

  course.sections = await Promise.all(
    course.sections.map(async (section) => {
      return await getSection({
        id: section.id,
        courseId: course.id,
        learnerId: user.id,
      });
    })
  );

  course.sections.sort((a, b) => a.pos - b.pos);

  // const pathname = usePathname();

  // const isFree = course.sections.every((section) => section.isFree);
  // const onClick = () => {
  //   router.push(`/course-enrolled/${course.id}/annoucement`);
  // };

  // const isActive = pathname?.endsWith(`/annoucement`);

  return (
    <div className="h-full border-r flex flex-col overflow-y-auto shadow-sm">
      <div className="p-8 flex flex-col border-b">
        <h1 className="font-semibold mt-8">{course.title}</h1>
        <CourseSidebarAnnouncement
          sectionId={course.id}
          label="Announcement"
          courseId={course.id}
          section={course}
        />
      </div>
      <div className="flex flex-col w-full">
        {course.sections.map((section) => (
          <CourseSidebarSection
            key={section.id}
            sectionId={section.id}
            label={section.title}
            courseId={course.id}
            section={section}
          />
        ))}
      </div>
    </div>
  );
};
