"use client";
import { cn } from "@/lib/utils";
import { CourseSection, Section } from "@/types/course";
import { BookOpen, CheckCircle, ClipboardType, File, Lock, PaperclipIcon, PuzzleIcon } from "lucide-react";
import { usePathname, useRouter } from "next/navigation";

interface CourseSidebarSectionProps {
  sectionId: number;
  label: string;
  courseId: number;
  section: any;
}

export const CourseSidebarSection = ({
  sectionId,
  label,
  courseId,
  section,
}: CourseSidebarSectionProps) => {
  const pathname = usePathname();
  const router = useRouter();
  console.log(section)
  const isLesson = section.lessonInfo;
  const isExercise = section.exerciseInfo;
  const Icon = section.lessonInfo ? BookOpen : section.exerciseInfo ? ClipboardType : PuzzleIcon;
  const isActive = pathname?.endsWith(`/${sectionId}`);


  const onClick = () => {
    router.push(`/course-enrolled/${courseId}/${sectionId}`);
  };
  return (
    <button
      onClick={onClick}
      type="button"
      className={cn(
        "flex items-center gap-x-2 p-4 text-slate-500 text-sm font-[500] pl-6 transition-all hover:text-slate-600 dark:hover:text-slate-400 hover:bg-slate-300 dark:hover:bg-gray-900",
        isActive &&
          "text-slate-700 bg-slate-200/20 dark:bg-gray-900 hover:bg-slate-200/20 dark:hover:bg-gray-900 hover:text-slate-700 dark:hover:text-slate-400",
        isLesson && "ms-6" || isExercise && "ms-6",
      )}
    >
      <div className="flex items-center gap-x-2 py-4">
        <Icon
          size={20}
          className={cn(
            "text-slate-500 dark:text-slate-400",
            isActive && "text-slate-700 dark:text-slate-400"
          )}
        />
        <span>{label}</span>
      </div>
      <div
        className={cn(
          "ml-auto opacity-0 border-2 border-slate-700 h-full transition-all",
          isActive && "opacity-100"
        )}
      />
    </button>
  );
};
