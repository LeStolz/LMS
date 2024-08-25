"use client";

import IconBadge from "@/components/icon-badge";
import { formatPrice } from "@/lib/format";
import { BookOpen, Lock, LockIcon } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { Button } from "@/components/ui/button";
import { ResponsiveDialog } from "@/components/responsive-dialog";
import { useState } from "react";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import PurchaseForm from "./purchase-form";

interface CourseItemsProps {
  id: number;
  title: string;
  image: string;
  price: number | undefined;
  sections?: any[];
  categories?: any[];
  user: any;
}

export const CourseItems = ({
  id,
  title,
  image,
  price,
  sections,
  categories,
  user,
}: CourseItemsProps) => {
  const [isPurchaseOpen, setIsPurchaseOpen] = useState(false);
  // let user;

  // try {
  //   user = await authorize(["LN"], true);
  // } catch {
  //   return redirect("/");
  // }

  // if (!user) {
  //   return redirect("/");
  // }
  return (
    <>
      <ResponsiveDialog
        isOpen={isPurchaseOpen}
        setIsOpen={setIsPurchaseOpen}
        title="Enroll Course"
        description="Are you sure you want to enroll this Course?"
      >
        <PurchaseForm
          user={user}
          setIsOpen={setIsPurchaseOpen}
          courseId={id}
          coursePrice={price}
        />
      </ResponsiveDialog>
      <div className="group hover:shadow-sm transition overflow-hidden border border-gray-100 dark:border-gray-900 rounded-lg p-3 h-full transition hover:bg-gray-300 hover:dark:bg-gray-800">
        <div className="relative w-full aspect-video rounded-md overflow-hidden">
          <Link href={`browse/${id}`}>
            <img
              className="object-cover w-full h-full"
              src={image}
              alt={title}
            />
          </Link>
        </div>
        <div className="flex flex-col pt-2">
          <div className="text-lg md:text-base font-medium group-hover:text-sky-700 transition line-clamp-2">
            {title}
          </div>
        </div>
        {categories && (
          <div className="flex flex-wrap gap-2 mt-2">
            {categories.map((category) => (
              <Badge key={category.id} variant="default">
                {category.title}
              </Badge>
            ))}
          </div>
        )}
        <div className="my-3 flex items-center justify-between gap-x-2 text-sm md:text-xs">
          <div className="flex items-center gap-x-1 text-slate-500">
            <IconBadge icon={BookOpen} size="sm" />
            <span>
              {" "}
              {sections?.filter((section) => section.type === "M").length ||
                0}{" "}
              Sections
            </span>
          </div>
          <Button
            variant="ghost"
            className="flex items-center space-x-1"
            onClick={() => {
              setIsPurchaseOpen(true);
            }}
          >
            <LockIcon className="h-4 w-4" />
            <span>Enroll</span>
          </Button>
        </div>
        <p className="text-md md:text-sm font-medium text-slate-700 dark:text-slate-100">
          {formatPrice(price ?? 0)}
        </p>
      </div>
    </>
  );
};
