"use client";

import { Button } from "@/components/ui/button";
import { Course } from "@/types/course";
import { ColumnDef } from "@tanstack/react-table";
import { ArrowUpDown, MoreHorizontal, Pencil, Trash } from "lucide-react";

import Link from "next/link";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Checkbox } from "@/components/ui/checkbox";

// This type is used to define the shape of our data.
// You can use a Zod schema here if you want.

const getStatusLabel = (status: any) => {
  switch (status) {
    case "C":
      return { label: "Created", color: "bg-yellow-500 text-white" };
    case "R":
      return { label: "Rejected", color: "bg-red-500 text-white" };
    case "P":
      return { label: "Pending", color: "bg-gray-500 text-black" };
    case "V":
      return { label: "Verified", color: "bg-green-500 text-white" };
    default:
      return { label: "Inactive", color: "bg-red-500 text-white" };
  }
};

export const columns: ColumnDef<Course>[] = [
  {
    id: "select",
    header: ({ table }) => (
      <Checkbox
        checked={
          table.getIsAllPageRowsSelected() ||
          (table.getIsSomePageRowsSelected() && "indeterminate")
        }
        onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        aria-label="Select all"
      />
    ),
    cell: ({ row }) => (
      <Checkbox
        checked={row.getIsSelected()}
        onCheckedChange={(value) => row.toggleSelected(!!value)}
        aria-label="Select row"
      />
    ),
    enableSorting: false,
    enableHiding: false,
  },

  {
    accessorKey: "email",
    header: "Email",
  },
  {
    accessorKey: "content",
    header: "Content",
  },
];
