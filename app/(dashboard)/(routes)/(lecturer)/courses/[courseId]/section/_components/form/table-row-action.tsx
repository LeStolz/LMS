"use client";

import { useState } from "react";

import DeleteForm from "../../../_components/chapter/delete-form";
import IconMenu from "@/components/icon-menu";
import { ResponsiveDialog } from "@/components/responsive-dialog";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Row } from "@tanstack/react-table";
import {
  BookText,
  LayoutDashboard,
  MoreHorizontal,
  NotepadText,
  Plus,
  Puzzle,
  SquarePen,
  Trash2,
} from "lucide-react";
import Link from "next/link";
import AddSection from "./add-section-form";
import AddLesson from "./add-lesson-form";
import AddExercise from "./add-exercise-form";

interface WithId<T, U> {
  courseId: T;
  sections: U[];
}
interface DataTableRowActionsProps<TData> {
  row: Row<TData>;
}

export function DataTableRowActions({
  courseId,
  sections,
}: {
  courseId: number;
  sections: any[];
}) {
  const [isAddSectionOpen, setIsAddSectionOpen] = useState(false);
  const [isAddLessonOpen, setIsAddLessonOpen] = useState(false);
  const [isAddExerciseOpen, setIsAddExerciseOpen] = useState(false);

  // const courseId = row.original.courseId as number;
  // const section = row.original.sections as any[];
  return (
    <>
      <ResponsiveDialog
        isOpen={isAddSectionOpen}
        setIsOpen={setIsAddSectionOpen}
        title="Add Section Course"
      >
        <AddSection
          courseId={courseId}
          sections={sections}
          setIsOpen={setIsAddSectionOpen}
        />
      </ResponsiveDialog>

      <ResponsiveDialog
        isOpen={isAddLessonOpen}
        setIsOpen={setIsAddLessonOpen}
        title="Add Lesson Course"
      >
        <AddLesson
          courseId={courseId}
          sections={sections}
          setIsOpen={setIsAddLessonOpen}
        />
      </ResponsiveDialog>

      <ResponsiveDialog
        isOpen={isAddExerciseOpen}
        setIsOpen={setIsAddExerciseOpen}
        title="Add Exercise Course"
      >
        <AddExercise
          courseId={courseId}
          sections={sections}
          setIsOpen={setIsAddExerciseOpen}
        />
      </ResponsiveDialog>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="outline"
            size="icon"
            className="overflow-hidden rounded-full"
          >
            <Plus className="h-5 w-5" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent
          align="end"
          side="right"
          className="w-[160px] z-50"
        >
          <DropdownMenuItem className="group flex w-full items-center justify-between  text-left p-0 text-sm font-base text-neutral-500 ">
            <button
              onClick={() => {
                setIsAddSectionOpen(true);
              }}
              className="w-full justify-start flex rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
            >
              <IconMenu
                text="Add Section"
                icon={<Puzzle className="h-4 w-4" />}
              />
            </button>
          </DropdownMenuItem>

          <DropdownMenuSeparator />

          <DropdownMenuItem className="group flex w-full items-center justify-between  text-left p-0 text-sm font-base text-neutral-500 ">
            <button
              onClick={() => {
                setIsAddLessonOpen(true);
              }}
              className="w-full justify-start flex rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
            >
              <IconMenu
                text="Add Lesson"
                icon={<BookText className="h-4 w-4" />}
              />
            </button>
          </DropdownMenuItem>

          <DropdownMenuSeparator />

          <DropdownMenuItem className="group flex w-full items-center justify-between  text-left p-0 text-sm font-base text-neutral-500 ">
            <button
              onClick={() => {
                setIsAddExerciseOpen(true);
              }}
              className="w-full justify-start flex rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
            >
              <IconMenu
                text="Add Exercise"
                icon={<NotepadText className="h-4 w-4" />}
              />
            </button>
          </DropdownMenuItem>


        </DropdownMenuContent>
      </DropdownMenu>
    </>
  );
}
