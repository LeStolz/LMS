"use client";

import IconBadge from "@/components/icon-badge";
import { formatPrice } from "@/lib/format";
import { BookOpen } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

interface CourseItemsProps {
  id: number;
  title: string;
  image: string;
  price: number | undefined;
}

export const CourseItems = ({
  id,
  title,
  image,
  price,
}: CourseItemsProps) => {
  return (
    <Link href={`browse/${id}`}>
      <div className="group hover:shadow-sm transition overflow-hidden border rounded-lg p-3 h-full">
        <div className="relative w-full aspect-video rounded-md overflow-hidden">
          <img
            className="object-cover w-full h-full"
            src={image}
            alt={title}
          />
        </div>
        <div className="flex flex-col pt-2">
          <div className="text-lg md:text-base font-medium group-hover:text-sky-700 transition line-clamp-2">
            {title}
          </div>
        </div>
        <p className="text-xs text-muted-foreground">Category</p>
        <div className="my-3 flex items-center gap-x-2 text-sm md:text-xs">
          <div className="flex items-center gap-x-1 text-slate-500">
            <IconBadge icon={BookOpen} size="sm" />
            <span> 1 Sections</span>
          </div>
          <p className="text-md md:text-sm font-medium text-slate-700">{formatPrice(price ?? 0)}</p>
        </div>
      </div>
    </Link>
  );
};