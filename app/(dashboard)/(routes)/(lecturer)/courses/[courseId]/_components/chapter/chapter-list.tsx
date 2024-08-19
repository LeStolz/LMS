"use client";

import { Section } from "@/types/course";
import React from "react";
import {
  DragDropContext,
  Draggable,
  Droppable,
  DropResult,
} from "@hello-pangea/dnd";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { Grip, Pencil, Trash } from "lucide-react";
import { Button } from "@/components/ui/button";
import { deleteCourseSection } from "@/app/api/course/[courseId]/route";
interface ChaptersListProps {
  items: any[];
  onReoder: (
    updateData: {
      id: number;
      pos: number;
      description: string;
      title: string;
    }[]
  ) => void;
  onEdit: (id: number) => void;
}

export const ChapterList = ({ items, onReoder, onEdit }: ChaptersListProps) => {
  const router = useRouter();
  const [isMounted, setIsMounted] = React.useState(false);
  console.log("items : ", items);
  const [sections, setSections] = React.useState<any[]>(
    items.sort((a, b) => a.pos - b.pos)
  );
  React.useEffect(() => {
    setIsMounted(true);
    // if(isMounted){
    //     onReoder(sections.map((section, index) => ({id: section.id, pos: index})));
    // }
  }, []);
  React.useEffect(() => {
    setSections(items);
  }, [items]);

  const onDragEnd = (result: DropResult) => {
    if (!result.destination) {
      return;
    }
    const items = Array.from(sections);
    const [reorderedItem] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, reorderedItem);

    const startIndex = Math.min(result.source.index, result.destination.index);
    const endIndex = Math.max(result.source.index, result.destination.index);

    const updateData = items
      .slice(startIndex, endIndex + 1)
      .map((section, index) => ({
        id: section.id,
        pos: items.findIndex((item) => item.id === section.id),
        title: section.title,
        description: section.description,
      }));

    console.log("updateData in chapter : ", updateData);

    setSections(items);
    onReoder(updateData);
  };

  const onDelete = async (id: number, courseId: number) => {
    try {
      await deleteCourseSection({ id, courseId });
      toast.success("Sections delete successfully");
      router.refresh();
      setSections(sections.filter((section) => section.id !== id));
    } catch (error) {
      console.error(error);
    }
  };

  if (!isMounted) {
    return null;
  }

  if (sections.length === 0) {
    return (
      <div className="text-center text-gray-500">No chapters available</div>
    );
  }

  return (
    <DragDropContext onDragEnd={onDragEnd}>
      <Droppable droppableId="chapters">
        {(provided) => (
          <div
            {...provided.droppableProps}
            ref={provided.innerRef}
            className="space-y-4"
          >
            {sections.map((section, index) => (
              <Draggable
                key={section.id}
                draggableId={section.id.toString()}
                index={index}
              >
                {(provided) => (
                  <div
                    ref={provided.innerRef}
                    {...provided.draggableProps}
                    {...provided.dragHandleProps}
                    className={cn(
                      "bg-gray-100 dark:bg-gray-700 rounded-md p-4",
                      "border border-gray-100 dark:border-gray-700",
                      "flex items-center justify-between",
                      "space-x-4",
                      "cursor-move"
                    )}
                  >
                    <div className="flex items-center space-x-4">
                      <Grip className="h-5 w-5" />
                      <div className="text-gray-500">{index + 1}</div>
                      <div className="font-medium">{section.title}</div>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Button
                        onClick={() => onEdit(section.id)}
                        type="button"
                        variant="ghost"
                        className="text-gray-500 hover:text-gray-700"
                      >
                        <Pencil className="h-5 w-5" />
                      </Button>
                      <Button
                        onClick={() => onDelete(section.id, section.courseId)}
                        variant="ghost"
                        type="button"
                        className="text-red-500 hover:text-red-700"
                      >
                        <Trash className="h-5 w-5" />
                      </Button>
                    </div>
                  </div>
                )}
              </Draggable>
            ))}
            {provided.placeholder}
          </div>
        )}
      </Droppable>
    </DragDropContext>
  );
};
