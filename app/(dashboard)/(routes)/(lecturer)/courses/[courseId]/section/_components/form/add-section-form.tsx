"use client";

import React, { Dispatch, SetStateAction } from "react";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useForm, FormProvider } from "react-hook-form";
import * as z from "zod";
import { deleteCourse } from "@/app/api/course/course";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  deleteCourseSection,
  insertCourseSection,
} from "@/app/api/course/[courseId]/route";
import { title } from "process";
import { Input } from "@/components/ui/input";

const formSchema = z.object({
  courseId: z.number(),
  title: z.string().nonempty("Title is required"),
  description: z.string().nonempty("Description is required"),
  pos: z.number(),
});

export default function AddSection({
  courseId,
  sections,
  setIsOpen,
}: {
  courseId: number;
  sections: any[];
  setIsOpen: Dispatch<SetStateAction<boolean>>;
}) {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      courseId: courseId,
      title: "",
      description: "",
      pos: sections.length + 1,
    },
  });

  const isLoading = form.formState.isSubmitting;
  const router = useRouter();

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    console.log("value", values);
    try {
      await insertCourseSection({
        courseId: courseId,
        title: values.title,
        pos: sections.length + 1,
        description: values.description,
      });
      toast.success("Sections Added successfully");
      router.refresh();
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <FormProvider {...form}>
      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(onSubmit)}
          className="space-y-6  sm:px-0 px-4"
        >
          <FormField
            control={form.control}
            name="title"
            render={({ field }) => (
              <FormItem className="flex-grow">
                <FormLabel>Title</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="Enter title"
                    {...field}
                    className="rounded-none"
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem className="flex-grow">
                <FormLabel>Description</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="Enter description"
                    {...field}
                    className="rounded-none"
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <div className="w-full flex justify-center sm:space-x-6">
            <Button
              size="lg"
              variant="outline"
              disabled={isLoading}
              className="w-full hidden sm:block"
              type="button"
              onClick={() => setIsOpen(false)}
            >
              Cancel
            </Button>
            <Button
              size="lg"
              type="submit"
              disabled={isLoading}
              className="w-full bg-green-500 hover:bg-green-400"
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Adding
                </>
              ) : (
                <span>Add</span>
              )}
            </Button>
          </div>
        </form>
      </Form>
    </FormProvider>
  );
}