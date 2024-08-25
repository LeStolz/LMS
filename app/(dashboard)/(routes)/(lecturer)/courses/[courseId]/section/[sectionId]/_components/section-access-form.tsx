"use client";

import * as z from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { LoaderCircleIcon, Pencil } from "lucide-react";
import React from "react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  updateCourseLesson,
  updateCourseSection,
} from "@/app/api/course/[courseId]/route";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";

interface SectionAcessFormProps {
  initialData: {
    title: string;
    description: string;
    lessonInfo: string;
    pos: number;
  };
  courseId: number;
  sectionId: number;
}

const formSchema = z.object({
  isFree: z.boolean().default(false),
});

export const SectionAcessForm = ({
  initialData,
  courseId,
  sectionId,
}: SectionAcessFormProps) => {
  const [isEditing, setIsEditing] = React.useState(false);
  const toggleEditing = () => setIsEditing((prev) => !prev);
  const router = useRouter();

  const lessonInfo = JSON.parse(initialData.lessonInfo);
  let isFree = false;
  if(initialData.lessonInfo){
    isFree = lessonInfo.length > 0 ? lessonInfo[0].isFree : false;
  }

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: { isFree },
  });

  const { isSubmitting, isValid } = form.formState;

  const [isLoading, setIsLoading] = React.useState(false);

  const onSubmit = async (data: z.infer<typeof formSchema>) => {
    console.log("data : ", data);
    try {
      setIsLoading(true);
      await updateCourseLesson({
        id: lessonInfo[0].id,
        courseId,
        title: initialData.title,
        description: initialData.description,
        pos: initialData.pos, // Keep the pos unchanged
        isFree: data.isFree,
        durationInMinutes: lessonInfo[0].durationInMinutes,
      });
      toast.success("Lesson Access updated successfully");
      toggleEditing();
      router.refresh();
    } catch (error) {
      toast.error("Failed to update section Description");
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = () => {
    form.handleSubmit(onSubmit)();
  };

  return (
    <div className="mt-6 border bg-gray-100 dark:bg-gray-700 rounded-md p-4">
      <div className="font-medium flex items-center justify-between">
        Lesson Access
        <div className="flex items-center gap-x-2">
          <Button
            onClick={toggleEditing}
            type="button"
            variant="ghost"
            className="p-0"
          >
            {isEditing ? (
              <>
                <Button type="button" variant="destructive">
                  Cancel
                </Button>
              </>
            ) : (
              <>
                <Button type="button" variant="ghost">
                  <Pencil className="h-4 w-4 mr-2" />
                  Edit
                </Button>
              </>
            )}
          </Button>
          {isEditing && (
            <Button
              type="submit"
              onClick={handleSubmit}
              disabled={!isValid || isSubmitting || isLoading}
            >
              {isLoading ? (
                <LoaderCircleIcon className="animate-spin" />
              ) : (
                "Update"
              )}
            </Button>
          )}
        </div>
      </div>
      {!isEditing && (
        <p className="text-sm mt-2">
          {initialData.lessonInfo && lessonInfo[0].isFree ? (
            <>This Lesson is free for preview</>
          ) : (
            <>This Lesson is not free</>
          )}
        </p>
      )}
      {isEditing && (
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-4 mt-4"
          >
            <FormField
              control={form.control}
              name="isFree"
              render={({ field }) => (
                <FormItem className="flex flex-row items-start space-x-3 space-y-0 rounded-md border p-4">
                  <FormControl>
                    <Checkbox
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  </FormControl>
                  <FormDescription>
                    Check this box if you want to make this lesson free for
                    preview
                  </FormDescription>
                  <FormMessage>
                    {form.formState.errors.isFree?.message}
                  </FormMessage>
                </FormItem>
              )}
            />
          </form>
        </Form>
      )}
    </div>
  );
};
