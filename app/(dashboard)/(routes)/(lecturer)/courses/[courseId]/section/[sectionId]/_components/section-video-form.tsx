"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { File, LoaderCircleIcon, Pencil, Trash } from "lucide-react";
import { useRouter } from "next/navigation";
import React from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import * as z from "zod";

import {
  deleteCourseSectionFile,
  insertCourseSectionFile,
} from "@/app/api/course/[courseId]/route";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { UploadDropzone } from "@/lib/uploadthing";
import MuxPlayer from "@mux/mux-player-react";

interface SectionVideoFormProps {
  courseId: number;
  sectionId: number;
  initialData: { files: string };
  type: string;
}

const formSchema = z.object({
  videos: z.array(
    z.object({
      name: z.string().min(1, { message: "Name is required" }),
      path: z.string().min(1, { message: "Path is required" }),
    })
  ),
});

export const SectionVideoForm = ({
  courseId,
  sectionId,
  initialData,
  type,
}: SectionVideoFormProps) => {
  const [isEditing, setIsEditing] = React.useState(false);
  const toggleEditing = () => setIsEditing((prev) => !prev);
  const router = useRouter();

  const files = JSON.parse(initialData.files);
  const defaultVideos = (files || []).map(
    (file: { id: string; name: string; path: string }) => {
      const [namePart, playbackIdPart] = file.name.split("|");
      return {
        id: file.id,
        name: namePart.trim(),
        playbackId: playbackIdPart ? playbackIdPart.trim() : "",
        path: file.path,
      };
    }
  );

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      videos: defaultVideos,
    },
  });

  const { isSubmitting, isValid } = form.formState;

  const [isLoading, setIsLoading] = React.useState(false);

  const onSubmit = async (data: z.infer<typeof formSchema>) => {
    try {
      setIsLoading(true);
      for (const video of data.videos) {
        await insertCourseSectionFile({
          courseId,
          courseSectionId: sectionId,
          path: video.path,
          name: video.name,
          isVideo: true,
        });
      }
      toast.success("Videos updated successfully");
      toggleEditing();
      router.refresh();
    } catch (error) {
      toast.error("Failed to update videos");
      router.refresh();
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = () => {
    form.handleSubmit(onSubmit)();
  };

  const handleDelete = async (index: number) => {
    try {
      await deleteCourseSectionFile({
        id: index,
      });
      toast.success("Videos delete successfully");
      toggleEditing();
      router.refresh();
    } catch (error) {
      toast.error("Failed to update videos");
      router.refresh();
    } finally {
    }
  };

  return (
    <div className="mt-6 border bg-gray-100 dark:bg-gray-700 rounded-md p-4">
      <div className="font-medium flex items-center justify-between">
        {type === "lesson"
          ? "Lesson Videos"
          : type === "exercise"
          ? "Exercise Videos"
          : "Section Videos"}
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
        </div>
      </div>
      {!isEditing && (
        <div className="space-y-4 mt-4">
          {defaultVideos.length === 0 ? (
            <p className="text-center">No video was found</p>
          ) : (
            defaultVideos.map((video: any, index: number) => {
              return (
                <>
                  <div
                    key={index}
                    className="flex items-center justify-between gap-x-2"
                  >
                    <div className="flex items-center gap-x-2">
                      <File size={24} />
                      <p className={`text-xs line-clamp-1`}>{video.name}</p>
                    </div>
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => handleDelete(video.id)}
                    >
                      <Trash className="h-4 w-4" />
                    </Button>
                  </div>
                  <div className="w-full">
                    <MuxPlayer playbackId={video.playbackId} />
                  </div>
                </>
              );
            })
          )}
        </div>
      )}
      {isEditing && (
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-4 mt-4"
          >
            {/* {form.watch("videos").map((video, index) => (
              <div key={index} className="space-y-4">
                <FormField
                  control={form.control}
                  name={`videos.${index}.name`}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Name</FormLabel>
                      <FormControl>
                        <Input
                          type="text"
                          disabled={isSubmitting}
                          placeholder="Video name"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage>
                        {form.formState.errors.videos?.[index]?.name?.message}
                      </FormMessage>
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name={`videos.${index}.path`}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Path</FormLabel>
                      <FormControl>
                        <Input
                          type="text"
                          disabled={isSubmitting}
                          placeholder="Video path"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage>
                        {form.formState.errors.videos?.[index]?.path?.message}
                      </FormMessage>
                    </FormItem>
                  )}
                />
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => handleDelete(index)}
                >
                  Delete
                </Button>
              </div>
            ))} */}
            <UploadDropzone
              endpoint="courseSectionVideo"
              onClientUploadComplete={async (res) => {
                const currentVideos = form.getValues("videos") || [];
                const newVideos = res.map((file) => ({
                  name: file.name,
                  path: file.url,
                }));
                form.setValue("videos", [...currentVideos, ...newVideos]);
                onSubmit(form.getValues());
              }}
              onUploadError={(error: Error) => {
                toast.error(error.message);
              }}
            />
          </form>
        </Form>
      )}
    </div>
  );
};
