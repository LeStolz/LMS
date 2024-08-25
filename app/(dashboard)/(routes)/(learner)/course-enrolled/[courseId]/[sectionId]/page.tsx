import { getSection } from "@/app/api/course/[courseId]/[sectionId]/route";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { VideoPlayer } from "./_components/video-player";

const SectionIdPage = async ({
  params,
}: {
  params: { courseId: string; sectionId: string };
}) => {
  const user = await authorize(["LN"]);
  if (!user) {
    return redirect("/");
  }

  const section = await getSection({
    id: parseInt(params.sectionId),
    courseId: parseInt(params.courseId),
    learnerId: user.id,
  });
  const lessonInFoArray = section.lessonInFo ? JSON.parse(section.lessonInFo) : [];
  const fileInFoArray = section.files ? JSON.parse(section.files) : [];
  const exerciseInFoArray = section.exerciseInFo ? JSON.parse(section.exerciseInFo) : [];
  const [fileName, playbackId] = fileInFoArray.length > 0 ? fileInFoArray[0].name.split("|") : ["", ""];
  const isLesson = section.lessonInfo;
  const isExercise = section.exerciseInfo;
  const isFree = lessonInFoArray.length > 0 ? lessonInFoArray[0].isFree : false;

  return (
    <div>
      <div className="flex flex-col max-w-4xl mx-auto pb-20">
        <div className="p-4">
          <VideoPlayer
            playbackId={playbackId}
            courseId={params.courseId}
            setionId={params.sectionId}
            // nextSectionId={lessonInFoArray[0].nextSectionId}
            isLocked={isFree}
            title={section.title}
          />
        </div>
      </div>
    </div>
  );
};

export default SectionIdPage;
