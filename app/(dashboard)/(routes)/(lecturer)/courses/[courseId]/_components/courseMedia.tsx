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

export default function CourseGeneral({
  onSubmit,
}: {
  onSubmit: (values: any) => any;
}) {
  const form = useFormContext();

  return (
    <div className="space-y-6 mt-6">
      <FormField
        control={form.control}
        name="thumbnail"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Thumbnail</FormLabel>
            <FormControl>
              <>
                {form.getValues("thumbnail") && (
                  <AspectRatio className="rounded-md" ratio={16 / 9}>
                    <Image
                      src={form.getValues("thumbnail")}
                      fill
                      alt="thumbnail"
                      className="object-cover rounded-md"
                    />
                  </AspectRatio>
                )}
                <UploadButton
                  className="pt-2"
                  endpoint="courseThumbnail"
                  onClientUploadComplete={async (res) => {
                    if (form.getValues("thumbnail") != res[0].url) {
                      await fetch("/api/uploadthing", {
                        method: "DELETE",
                        body: JSON.stringify({
                          url: form.getValues("thumbnail"),
                        }),
                      });
                    }

                    form.setValue("thumbnail", res[0].url);
                    onSubmit(form.getValues());
                  }}
                  onUploadError={(error: Error) => {
                    toast.error(error.message);
                  }}
                />
              </>
            </FormControl>
            <FormDescription>
              Thumbnail is required for publishing and should be 16:9 ratio.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="advertisementVideo"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Promotional video</FormLabel>
            <FormControl>
              <>
                {form.getValues("advertisementVideo") && (
                  <AspectRatio className="relative rounded-md" ratio={16 / 9}>
                    <iframe
                      src={form.getValues("advertisementVideo")}
                      about="advertisementVideo"
                      className="absolute rounded-md w-full h-full"
                    />
                  </AspectRatio>
                )}
                <UploadButton
                  className="pt-2"
                  endpoint="courseAdvertisementVideo"
                  onClientUploadComplete={async (res) => {
                    if (form.getValues("advertisementVideo") != res[0].url) {
                      await fetch("/api/uploadthing", {
                        method: "DELETE",
                        body: JSON.stringify({
                          url: form.getValues("advertisementVideo"),
                        }),
                      });
                    }

                    form.setValue("advertisementVideo", res[0].url);
                    onSubmit(form.getValues());
                  }}
                  onUploadError={(error: Error) => {
                    toast.error(error.message);
                  }}
                />
              </>
            </FormControl>
            <FormDescription>
              Promotional video should be 16:9 ratio.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
