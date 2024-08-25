import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { UploadButton } from "@/lib/uploadthing";
import { AspectRatio } from "@radix-ui/react-aspect-ratio";
import Image from "next/image";
import { useFormContext } from "react-hook-form";
import { toast } from "sonner";
import { File, LoaderCircleIcon, PlusCircle } from "lucide-react";
import { UploadDropzone } from "@/lib/uploadthing";
import { FileRouter } from "uploadthing/types";
import { Button } from "@/components/ui/button";
import React from "react";

type MyFileRouter = FileRouter; // Replace with your actual FileRouter type
type MyEndpoint = keyof MyFileRouter;

export default function CourseGeneral({
  onSubmit,
}: {
  onSubmit: (values: any) => any;
}) {
  const form = useFormContext();
  const [files, setFiles] = React.useState<FileRouter[]>([]);
  const [uploading, setUploading] = React.useState(false);
  const [deletingId, setDeletingId] = React.useState<string | null>(null);
  const onDelete = async (url: string) => {
    try {
      setDeletingId(url);
      await fetch("/api/uploadthing", {
        method: "DELETE",
        body: JSON.stringify({ url }),
      });
      toast.success("File deleted successfully.");
    } catch (error: any) {
      toast.error(error.message);
    }
  };
  return (
    <div className="space-y-6 mt-6">
      <FormField
        control={form.control}
        name="resources"
        render={({ field }) => (
          <FormItem className="rounded-md">
            <FormLabel className="flex items-center gap-x-2">
              <h2 className="text-xl">Resources & Attachment</h2>
            </FormLabel>
            <FormControl>
              <>
                {form.getValues("resources")?.length > 0 && (
                  <div className="space-y-4">
                    {form
                      .getValues("resources")
                      .map((resource: string, index: number) => (
                        <AspectRatio
                          key={index}
                          className="rounded-md"
                          ratio={16 / 1}
                        >
                          <div className="flex items-center p-3 w-full bg-sky-100 border-sky-200 border text-sky-700 rounded-sm">
                            <div className="flex items-center gap-x-2">
                              <File size={24} />
                              <span className="text-xs line-clamp-1">
                                {resource.split("/").pop()}
                              </span>
                              <Button
                                variant="destructive"
                                size="sm"
                                onClick={async () => {
                                  // Remove the file from the form state
                                  const currentResources =
                                    form.getValues("resources") || [];
                                  const updatedResources =
                                    currentResources.filter(
                                      (_: any, i: number) => i !== index
                                    );
                                  form.setValue("resources", updatedResources);

                                  // Delete the file from the server
                                  await fetch("/api/uploadthing", {
                                    method: "DELETE",
                                    body: JSON.stringify({ url: resource }),
                                  });

                                  // Submit the updated form values
                                  onSubmit(form.getValues());
                                }}
                              >
                                {deletingId ? (
                                  <LoaderCircleIcon className="animate-spin" />
                                ) : (
                                  "Delete"
                                )}
                              </Button>
                            </div>
                          </div>
                        </AspectRatio>
                      ))}
                  </div>
                )}
                <UploadDropzone
                  endpoint="courseSectionFile"
                  //   multiple={true}
                  onClientUploadComplete={async (res) => {
                    const currentResources = form.getValues("resources") || [];
                    const newResources = res.map((file) => file.url);

                    // Delete old files if they are not in the new resources
                    const filesToDelete = currentResources.filter(
                      (resource: string) => !newResources.includes(resource)
                    );
                    for (const file of filesToDelete) {
                      await fetch("/api/uploadthing", {
                        method: "DELETE",
                        body: JSON.stringify({ url: file }),
                      });
                    }

                    form.setValue("resources", [
                      ...currentResources,
                      ...newResources,
                    ]);
                    onSubmit(form.getValues());
                  }}
                  onUploadError={(error: Error) => {
                    toast.error(error.message);
                  }}
                />
              </>
            </FormControl>
            <FormDescription>
              Add anything your students might need to complete the course.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
