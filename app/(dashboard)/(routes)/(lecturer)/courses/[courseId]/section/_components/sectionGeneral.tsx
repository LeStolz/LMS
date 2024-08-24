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
    Plus,
    PlusCircle,
    Trash,
  } from "lucide-react";
  import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
  } from "@/components/ui/dropdown-menu";
  import { UploadDropzone } from "@/lib/uploadthing";
  import { FileRouter } from "uploadthing/types";
  import { Button } from "@/components/ui/button";
  import { z } from "zod";
  import { zodResolver } from "@hookform/resolvers/zod";
  import React from "react";
  import { Input } from "@/components/ui/input";
  import { ChapterList } from "./chapter-list";
  import { updateCourseSection } from "@/app/api/course/[courseId]/route";
  import { useRouter } from "next/navigation";
  import { cn } from "@/lib/utils";
import { DataTableRowActions } from "./form/table-row-action";
  
  export default function SectionGeneral({courseId, sections }: { courseId: number, sections: any[] }) {
    // let courseId: any;
    // // const form = useFormContext();
    // if (sections.length !== 0) {
    //   courseId = sections[0].courseId;
    // }
    const router = useRouter();
    const [isEditing, setIsEditing] = React.useState(false);
    const toggleEditing = () => setIsEditing((prev) => !prev);
  
    // const {
    //   fields: sectionField,
    //   append: appendSection,
    //   remove: removeSection,
    // } = useFieldArray({
    //   control: form.control,
    //   name: "sections",
    // });
  
    // const addSection = () => {
    //   const length = sectionField.length;
    //   const pos = length + 1;
    //   appendSection({ pos, title: "", description: "" });
    // };
  
    const onReoder = async (
      updateData: {
        id: number;
        pos: number;
        description: string;
        title: string;
      }[]
    ) => {
      try {
        console.log("updateData : ", updateData);
        for (const data of updateData) {
          console.log("data : ", data);
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
        // form.setValue("sections", sectionField);
      }
    };
  
    const onEdit = (id: number) => {
      router.push(`/courses/${courseId}/section/${id}`);
    };
  
    // console.log(sectionField);
  
    return (
      <div className="mt-6 border bg-slate-200 dark:bg-slate-800 rounded-md p-4">
        <div className="font-medium flex items-center justify-between">
          Section
          <DataTableRowActions courseId={courseId} sections={sections}/>
        </div>
        <div className="p-2">
          {sections.length === 0 ? (
            <div
              className={cn(
                "bg-gray-100 dark:bg-gray-700 rounded-md p-4",
                "border border-gray-100 dark:border-gray-700",
                "flex items-center justify-between",
                "space-x-4",
              )}
            >
              <p>No Founded Section</p>
            </div>
          ) : (
            <ChapterList onEdit={onEdit} onReoder={onReoder} items={sections} />
          )}
        </div>
      </div>
    );
  }
  