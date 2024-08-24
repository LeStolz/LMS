"use client";

import * as z from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { LoaderCircleIcon, Pencil } from "lucide-react";
import React from "react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";

import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { updateCourseSection } from "@/app/api/course/[courseId]/route";
import { Textarea } from "@/components/ui/textarea";

interface SectionDescriptionFormProps {
  initialData: { title: string; description: string; pos: number };
  courseId: number;
  sectionId: number;
}

const formSchema = z.object({
  description: z.string().min(1, { message: "Description is required" }),
});

export const SectionDescriptionForm = ({
  initialData,
  courseId,
  sectionId,
}: SectionDescriptionFormProps) => {
  const [isEditing, setIsEditing] = React.useState(false);
  const toggleEditing = () => setIsEditing((prev) => !prev);
  const router = useRouter();
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: initialData,
  });

  const { isSubmitting, isValid } = form.formState;

  const [isLoading, setIsLoading] = React.useState(false);

  const onSubmit = async (data: z.infer<typeof formSchema>) => {
    try {
      setIsLoading(true);
      await updateCourseSection({
        courseId,
        id: sectionId,
        title: initialData.title,
        description: data.description,
        pos: initialData.pos, // Keep the pos unchanged
      });
      toast.success("Section title and description updated successfully");
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
        Section Description
        <div className="flex items-center gap-x-2">
          <Button onClick={toggleEditing} type="button" variant="ghost" className="p-0">
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
                "Update Description"
              )}
            </Button>
          )}
        </div>
      </div>
      {!isEditing && <p className="text-sm mt-2">{initialData.description}</p>}
      {isEditing && (
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-4 mt-4"
          >
            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Description</FormLabel>
                  <FormControl>
                    <Textarea
                      disabled={isSubmitting}
                      placeholder="Tell us a bit more about your course"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage>
                    {form.formState.errors.description?.message}
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
