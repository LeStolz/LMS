"use client";

import { Dispatch, SetStateAction } from "react";

import {
    insertCourseExercise
} from "@/app/api/course/[courseId]/route";
import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import * as z from "zod";

const formSchema = z.object({
  courseId: z.number(),
  title: z.string().nonempty("Title is required"),
  description: z.string().nonempty("Description is required"),
  pos: z.number(),
  type: z.enum(["E", "Q"]).optional(),
});

export default function AddExercise({
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
      type: "E",
    },
  });

  const isLoading = form.formState.isSubmitting;
  const router = useRouter();

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    console.log("value", values);
    try {
      await insertCourseExercise({
        courseId: courseId,
        title: values.title,
        pos: sections.length + 1,
        description: values.description,
        type: values.type ?? undefined,
      });
      toast.success("Lessons added successfully");
      router.refresh();
    } catch (error) {
      console.log(error);
    }
  };

  return (
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
        <FormField
          control={form.control}
          name="type"
          render={({ field }) => (
            <FormItem>
              <FormLabel>type</FormLabel>
              <Select
                {...field}
                onValueChange={field.onChange}
                defaultValue={field.value}
              >
                <FormControl>
                  <SelectTrigger id="type" className="w-full">
                    <SelectValue placeholder="Select exercise type" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="E">E</SelectItem>
                  <SelectItem value="Q">Q</SelectItem>
                </SelectContent>
              </Select>
              <FormDescription>
                Course exercise type is required for publishing.
              </FormDescription>
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
  );
}
