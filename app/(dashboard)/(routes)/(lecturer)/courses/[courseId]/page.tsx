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
import { createCourse, getCourse } from "@/app/api/course/course";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { useQuery } from "@tanstack/react-query";
import { useAuth } from "@/providers/auth-provider";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import CourseGeneral from "./_components/courseGeneral";

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
  // HERE
  description: z
    .string()
    .min(200, {
      message: "Description must be at least 200 characters long.",
    })
    .max(512, {
      message: "Description must not be longer than 512.",
    }),
  level: z.enum(["B", "I", "A"], {
    message: "Level is required.",
  }),
  thumbnail: z.string().url({
    message: "Thumbnail must be a valid URL.",
  }),
  advertisementVideo: z
    .string()
    .url({
      message: "Advertisement video must be a valid URL.",
    })
    .nullable(),
  price: z.coerce.number().min(0, {
    message: "Price must be non-negative.",
  }),
});

export default function Component({
  params,
}: {
  params: { courseId: string };
}) {
  const router = useRouter();

  const { user } = useAuth();

  if (!user.isLoading && (!user.data || user.data.type != "LT")) {
    router.push("/");
    return;
  }

  const course = useQuery({
    queryKey: ["course", params.courseId],
    queryFn: () => getCourse({ id: parseInt(params.courseId) }),
  });

  if (!course.isLoading && !course.data) {
    router.push("/");
    return;
  }

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  });
  const { isSubmitting, isValid } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      const course = await createCourse(values);

      toast.success("Course saved!");
    } catch (error) {
      setError(formatError(error));
    }
  }

  return (
    <div className="container px-0 max-w-2xl">
      <h1 className="text-2xl font-bold pb-4">Update course</h1>

      <FormProvider {...form}>
        <Form {...form}>
          <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
            <Tabs defaultValue="general" className="w-full">
              <TabsList>
                <TabsTrigger value="general">General</TabsTrigger>
                <TabsTrigger value="sections">Sections</TabsTrigger>
                <TabsTrigger value="billings">Billings</TabsTrigger>
              </TabsList>
              <TabsContent value="general">
                <CourseGeneral />
              </TabsContent>
              <TabsContent value="sections">Sections</TabsContent>
              <TabsContent value="billings">Billings</TabsContent>
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
    </div>
  );
}
