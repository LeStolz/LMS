import { ReactNode, Suspense } from "react";
import { redirect } from "next/navigation";
import { authorize } from "@/app/api/user/user";
import { getCourse } from "@/app/api/course/[courseId]/route";
import { Eye, File, LayoutDashboard, Loader2, Video } from "lucide-react";
import { getSection } from "@/app/api/course/[courseId]/[sectionId]/route";
import IconBadge from "@/components/icon-badge";
import { SectionTitleForm } from "./_components/section-title-form";
import { SectionDescriptionForm } from "./_components/section-description-form";
import { SectionAcessForm } from "./_components/section-access-form";
import { SectionVideoForm } from "./_components/section-video-form";
import { SectionFileForm } from "./_components/section-file-form";

export default async function Component({
  params,
}: {
  params: { courseId: string; sectionId: string };
}) {
  console.log("params : ", params);
  const section = await getSection({
    id: parseInt(params.sectionId),
    courseId: parseInt(params.courseId),
  });

  console.log("Section fetch", section);

  // if (!section) {
  //   return redirect(`/courses/${params.courseId}`);
  // }
  const requestFields = Object.values(section);
  const totalFields = requestFields.length;
  const completedFields = requestFields.filter((field) => field).length;
  const progress = Math.round((completedFields / totalFields) * 100);
  const completeFields = `${completedFields}/${totalFields}`;

  const type = section.lessonInfo
    ? "lesson"
    : section.exerciseInfo
    ? "exercise"
    : "section";

  return (
    <div className="container p-6">
      <div className="flex items-center justify-between">
        <div className="w-full">
          <div className="flex flex-col gap-y-2">
            <h1 className="text-2xl font-bold pb-4">
              {type === "lesson"
                ? "Lesson Creation"
                : type === "exercise"
                ? "Exercise Creation"
                : "Section Creation"}
            </h1>
            <span className="text-sm text-slate-300">
              Complete all fields {completeFields}
            </span>
          </div>
          <div className="grid gid-cols-1 md:grid-cols-2 gap-6 mt-16">
            <div className="space-y-4">
              <div>
                <div className="flex items-center gap-x-2">
                  <IconBadge icon={LayoutDashboard} />
                  <h2>Customize your Section</h2>
                </div>
                <SectionTitleForm
                  initialData={section}
                  courseId={parseInt(params.courseId)}
                  sectionId={parseInt(params.sectionId)}
                  type={type}
                />

                <SectionDescriptionForm
                  initialData={section}
                  courseId={parseInt(params.courseId)}
                  sectionId={parseInt(params.sectionId)}
                  type={type}
                />
              </div>

              {section.lessonInfo ? (
                <div>
                  <div className="flex items-center gap-x-2 gap-y-2">
                    <IconBadge icon={Eye} />
                    <h2>Acess Setting</h2>
                  </div>

                  <SectionAcessForm
                    initialData={section}
                    courseId={parseInt(params.courseId)}
                    sectionId={parseInt(params.sectionId)}
                  />
                </div>
              ) : (
                ""
              )}

              <div>
                <div className="flex items-center gap-x-2 gap-y-2">
                  <IconBadge icon={Video} />
                  <h2>Add a Video</h2>
                </div>
                <SectionVideoForm
                  courseId={parseInt(params.courseId)}
                  sectionId={parseInt(params.sectionId)}
                  initialData={section}
                  type={type}
                />
              </div>
            </div>
            <div className="space-y-4">
              <div className="flex items-center gap-x-2 gap-y-2">
                <IconBadge icon={File} />
                <h2>Add a FIle</h2>
              </div>
              <SectionFileForm
                courseId={parseInt(params.courseId)}
                sectionId={parseInt(params.sectionId)}
                initialData={section}
                type={type}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
