"use client";

import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { LoaderCircleIcon } from "lucide-react";
import { Input } from "@/components/ui/input";
import Link from "next/link";
import { formatError } from "@/lib/utils";
import { createCourse } from "@/app/api/course/course";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

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
  
});

export default function Component() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  });
  const { isSubmitting, isValid } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);
  const router = useRouter();

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      console.log(values);
      // const id = await getSessionId();
      // setUserId(id);
      const course = await createCourse(values);
      router.push(`/courses/${course.id}`);

      toast.success("Course created!");
    } catch (error) {
      setError(formatError(error));
    }
  }

  return (
    <div className="container px-0 max-w-2xl">
      <h1 className="text-2xl font-bold">Name your course</h1>
      <p className="text-muted-foreground">
        Think about what you would like to teach in your course.
      </p>
      <p className="text-muted-foreground pb-4">
        Dont worry, you can change this later.
      </p>

      <Form {...form}>
        <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
          <FormField
            control={form.control}
            name="title"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Title</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="Enter course title"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="subtitle"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Subtitle</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="Enter course subtitle"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
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
                  "Continue"
                )}
              </Button>
            </div>
            {error && <FormMessage className="pt-2">{error}</FormMessage>}
          </div>
        </form>
      </Form>
    </div>
  );
}
