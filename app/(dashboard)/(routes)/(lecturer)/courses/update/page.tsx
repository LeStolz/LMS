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
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { LoaderCircleIcon } from "lucide-react";
import { Input } from "@/components/ui/input";

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

export default function CourseForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  });
  const { isSubmitting, isValid } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setError("");
  }

  return (
    <div className="container max-w-2xl">
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
          <FormField
            control={form.control}
            name="level"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Level</FormLabel>
                <Select
                  required
                  {...field}
                  onValueChange={field.onChange}
                  defaultValue={field.value}
                >
                  <FormControl>
                    <SelectTrigger id="type" className="w-full">
                      <SelectValue placeholder="Select course level" />
                    </SelectTrigger>
                  </FormControl>
                  <SelectContent>
                    <SelectItem value="B">Beginner</SelectItem>
                    <SelectItem value="I">Intermediate</SelectItem>
                    <SelectItem value="A">Advanced</SelectItem>
                  </SelectContent>
                </Select>
                <FormMessage />
              </FormItem>
            )}
          />
          <div>
            <Button
              type="submit"
              className="w-full"
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
                "Create course"
              )}
            </Button>
            {error && <FormMessage className="pt-2">{error}</FormMessage>}
          </div>
        </form>
      </Form>
    </div>
  );
}
