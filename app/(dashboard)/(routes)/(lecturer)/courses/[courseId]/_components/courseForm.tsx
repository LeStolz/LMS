"use client";

import { FormProvider, useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { Form, FormMessage } from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { LoaderCircleIcon } from "lucide-react";
import Link from "next/link";
import { formatError } from "@/lib/utils";
import { toast } from "sonner";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Course, CourseCategories } from "@/types/course";
import CourseGeneral from "./courseGeneral";
import { useRouter } from "next/navigation";
import { updateCourse } from "@/app/api/course/course";
import CourseMedia from "./courseMedia";
import CourseResource from "./courseResource";

const formSchema = z.object({
  title: z
    .string()
    .min(1, {
      message: "Title is required.",
    })
    .max(60, {
      message: "Title must not be longer than 60.",
    }),
  subtitle: z
    .string()
    .min(1, {
      message: "Subtitle is required.",
    })
    .max(120, {
      message: "Subtitle must not be longer than 120.",
    }),
  description: z.string().optional(),
  level: z.enum(["B", "I", "A"]).optional(),
  thumbnail: z.string().url().optional(),
  advertisementVideo: z.string().url().optional(),
  price: z.coerce.number().min(0, {
    message: "Price must be non-negative.",
  }),
  categoryIds: z.any(),
});

export default function Component({
  course,
}: {
  course: Course & CourseCategories;
}) {
  const router = useRouter();
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      ...course,
      level: course.level ?? undefined,
      description: course.description ?? undefined,
      price: course.price ?? 0,
      categoryIds: course.categories.map((category) => {
        return {
          value: category.id,
          name: category.title,
        };
      }),
    },
  });
  const { isSubmitting, isValid } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      await updateCourse({
        ...values,
        categoryIds: values.categoryIds.map(
          ({ value }: { value: number | string }) => {
            return typeof value === "string" ? parseInt(value) : value;
          }
        ),
        description: values.description ?? undefined,
        level: values.level ?? undefined,
        thumbnail: values.thumbnail ?? undefined,
        advertisementVideo: values.advertisementVideo ?? undefined,
        id: course.id,
        updatedAt: new Date(),
      });

      toast.success("Course saved!");

      router.refresh();
      setError(undefined);
    } catch (error) {
      setError(formatError(error));
    }
  }

  return (
    <FormProvider {...form}>
      <Form {...form}>
        <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
          <Tabs defaultValue="general" className="w-full">
            <TabsList>
              <TabsTrigger value="general">General</TabsTrigger>
              <TabsTrigger value="media">Media</TabsTrigger>
              <TabsTrigger value="sections">Sections</TabsTrigger>
              <TabsTrigger value="billings">Billings</TabsTrigger>
              <TabsTrigger value="resource">Resources</TabsTrigger>
            </TabsList>
            <TabsContent value="general">
              <CourseGeneral />
            </TabsContent>
            <TabsContent value="media">
              <CourseMedia onSubmit={onSubmit} />
            </TabsContent>
            <TabsContent value="sections">Sections</TabsContent>
            <TabsContent value="billings">Billings</TabsContent>
            <TabsContent value="resource">
              <CourseResource onSubmit={onSubmit}/>
            </TabsContent>
          </Tabs>
          <div>
            <div className="flex flex-row gap-2">
              <Link href="/courses">
                <Button type="button" variant="ghost">
                  Cancel
                </Button>
              </Link>
              <Button
                type="submit"
                aria-disabled={isSubmitting}
                onClick={(event: any) => {
                  if (isSubmitting) {
                    event.preventDefault();
                  }
                }}
              >
                {isSubmitting ? (
                  <LoaderCircleIcon className="animate-spin" />
                ) : (
                  "Save"
                )}
              </Button>
            </div>
            {error && <FormMessage className="pt-2">{error}</FormMessage>}
          </div>
        </form>
      </Form>
    </FormProvider>
  );
}
