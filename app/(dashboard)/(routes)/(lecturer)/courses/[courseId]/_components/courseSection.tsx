import {
  Form,
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
import { useFieldArray, useFormContext } from "react-hook-form";
import { toast } from "sonner";
import {
  File,
  LoaderCircleIcon,
  Pencil,
  PlusCircle,
  Trash,
} from "lucide-react";
import { UploadDropzone } from "@/lib/uploadthing";
import { FileRouter } from "uploadthing/types";
import { Button } from "@/components/ui/button";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import React from "react";
import { Input } from "@/components/ui/input";
import { ChapterList } from "./chapter/chapter-list";
import { updateCourseSection } from "@/app/api/course/[courseId]/route";
import { useRouter } from "next/navigation";

export default function CourseSection({sections} : {sections : any[]}) {
  const form = useFormContext();
  const courseId = sections[0].courseId;
  const router = useRouter();
  const [isEditing, setIsEditing] = React.useState(false);
  const toggleEditing = () => setIsEditing((prev) => !prev);

  const {
    fields: sectionField,
    append: appendSection,
    remove: removeSection,
  } = useFieldArray({
    control: form.control,
    name: "sections",
  });

  const addSection = () => {
    const length = sectionField.length;
    const pos = length + 1;
    appendSection({ pos, title: "", description: "" });
  };

  const onReoder = async (updateData: { id: number; pos: number; description : string;title : string  }[]) => {
    try {
      console.log('updateData : ', updateData);
      for (const data of updateData) {
        console.log('data : ', data);
        await updateCourseSection({
          courseId: courseId,
          id: data.id,
          title: data.title,
          description: data.description,
          pos: data.pos,
        });
      }

      toast.success("Sections reordered successfully");
      router.refresh();
    } catch (error) {
      toast.error("Failed to reorder sections");
    } finally {
      form.setValue("sections", sectionField);
    }
  }

  const onEdit = (id: number) => {
    router.push(`/courses/${courseId}/${id}`);
  }

  console.log(sectionField);

  return (
    <div className="mt-6 border bg-slate-200 dark:bg-slate-800 rounded-md p-4">
      <div className="font-medium flex items-center justify-between">
        Section
        <Button onClick={toggleEditing} variant="default" type="button">
          {isEditing ? (
            <>Cancel</>
          ) : (
            <>
              <Pencil size={24} />
              Edit Section
            </>
          )}
        </Button>
      </div>
      {!isEditing && (
        <ChapterList
        onEdit={onEdit}
        onReoder={onReoder}
        items={sections}
        />
      )}
      {isEditing && (
        <div className="mt-4">
          {sectionField.map((section, index) => (
            <div key={section.id} className="space-y-4">
              <FormField
                control={form.control}
                name={`sections.${index}.title`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Title</FormLabel>
                    <Input type="text"
                      placeholder="enter the section title"
                       {...field} />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name={`sections.${index}.description`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <Input
                      type="text"
                      placeholder="enter the section description"
                      {...field}
                    />
                  </FormItem>
                )}
              />
              {/* <FormField
                control={form.control}
                name={`sections.${index}.type`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Type</FormLabel>
                    <Input {...field} />
                  </FormItem>
                )}
              /> */}
              <Button
                onClick={() => removeSection(index)}
                variant="destructive"
                type="button"
              >
                <Trash size={24} />
                Remove Section
              </Button>
            </div>
          ))}
          <Button onClick={addSection} variant="ghost" type="button">
            <PlusCircle size={24} />
            Add Section
          </Button>
        </div>
      )}
    </div>
  );
}
