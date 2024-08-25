"use client";

import { useState } from "react";

import RejecteForm from "./_components/reject-form";
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
  Clipboard,
  ClipboardPlus,
  ClipboardX,
  Eye,
  EyeOff,
  LayoutDashboard,
  MoreHorizontal,
  SquarePen,
  Trash2,
} from "lucide-react";
import Link from "next/link";
import AcceptForm from "./_components/accepte-form";

interface WithId<T> {
  id: number;
  status: string;
}
interface DataTableRowActionsProps<TData> {
  row: Row<TData>;
}

export function DataTableRowActions<TData extends WithId<number>>({
  row,
}: DataTableRowActionsProps<TData>) {
  const [isAccepteOpen, setIsAccepteOpen] = useState(false);
  const [isRejectOpen, setIsRejectOpen] = useState(false);
  const [isRefactorOpen, setIsRefactorOpen] = useState(false);
  const cardId = row.original.id as number;
  const type = row.original.status as string;

  return (
    <>
      <ResponsiveDialog
        isOpen={isRejectOpen}
        setIsOpen={setIsRejectOpen}
        title="Reject Course"
        description="Are you sure you want to reject this Course?"
      >
        <RejecteForm cardId={cardId} setIsOpen={setIsRejectOpen} />
      </ResponsiveDialog>

      <ResponsiveDialog
        isOpen={isAccepteOpen}
        setIsOpen={setIsAccepteOpen}
        title="Verify Course"
        description="Are you sure you want to accept this Course?"
      >
        <AcceptForm cardId={cardId} setIsOpen={setIsAccepteOpen} />
      </ResponsiveDialog>

      <ResponsiveDialog
        isOpen={isRefactorOpen}
        setIsOpen={setIsRefactorOpen}
        title="Add Course to pending"
        description="Are you sure you want to refactor this Course?"
      >
        <AcceptForm cardId={cardId} setIsOpen={setIsRefactorOpen} />
      </ResponsiveDialog>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" className="h-8 w-8 p-0">
            <span className="sr-only">Open menu</span>
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" side="right" className="w-[160px] z-50">
          <Link href={`/courses/${cardId}`}>
            <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
              <button className="w-full justify-start flex rounded-md p-2 transition-all duration-75 hover:bg-neutral-100">
                <IconMenu text="View Details" icon={<Eye className="h-4 w-4" />} />
              </button>
            </DropdownMenuItem>
          </Link>
          <DropdownMenuSeparator />

          {type === "P" && (
            <>
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsAccepteOpen(true);
                  }}
                  className="w-full justify-start flex text-green-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Accept" icon={<ClipboardPlus className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsRejectOpen(true);
                  }}
                  className="w-full justify-start flex text-red-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Reject" icon={<ClipboardX className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
            </>
          )}

          {type === "V" && (
            <>
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsRefactorOpen(true);
                  }}
                  className="w-full justify-start flex text-blue-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Refactor" icon={<SquarePen className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsRejectOpen(true);
                  }}
                  className="w-full justify-start flex text-red-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Reject" icon={<ClipboardX className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
            </>
          )}

          {type === "R" && (
            <>
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsRefactorOpen(true);
                  }}
                  className="w-full justify-start flex text-blue-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Refactor" icon={<SquarePen className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="group flex w-full items-center justify-between text-left p-0 text-sm font-base text-neutral-500">
                <button
                  onClick={() => {
                    setIsAccepteOpen(true);
                  }}
                  className="w-full justify-start flex text-green-500 rounded-md p-2 transition-all duration-75 hover:bg-neutral-100"
                >
                  <IconMenu text="Verify" icon={<ClipboardPlus className="h-4 w-4" />} />
                </button>
              </DropdownMenuItem>
            </>
          )}
        </DropdownMenuContent>
      </DropdownMenu>
    </>
  );
}