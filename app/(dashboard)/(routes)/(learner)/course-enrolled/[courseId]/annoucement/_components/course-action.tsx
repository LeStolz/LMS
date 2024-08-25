"use client";

import { demandCourseVerification } from "@/app/api/course/[courseId]/route";
import { Button } from "@/components/ui/button";
import { Loader2, Router, Trash } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

interface ChapterActionsProps {
  disabled: boolean;
  courseId: number;
  isPublished: boolean;
}

export const ChapterActions = ({
  disabled,
  courseId,
  isPublished,
}: ChapterActionsProps) => {
  const [isLoading, setIsLoading] = useState(false);
  const route = useRouter();
  const onPublish = async () => {
    try {
      setIsLoading(true);
      await demandCourseVerification({
        id: courseId,
      });
      toast.success("Course published successfully");
      route.refresh()
    } catch (error: any) {
      console.error(error);
      toast.error(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex items-center gap-x-2">
      <Button
        onClick={onPublish}
        disabled={disabled || isLoading}
        variant="outline"
        size="sm"
      >
        {isLoading ? (<Loader2 size={20}/> ) : isPublished ? "Unpublish" : "Publish"}
      </Button>
      <Button disabled={isLoading}>
        <Trash className="h-4 w-4" />
      </Button>
    </div>
  );
};