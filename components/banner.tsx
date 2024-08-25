import {
  AlertCircle,
  AlertTriangle,
  CheckCircleIcon,
  FileWarning,
  Icon,
} from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";
import exp from "constants";
import { Button } from "./ui/button";
import { ChapterActions } from "@/app/(dashboard)/(routes)/(lecturer)/courses/_components/course-action";

const bannerVariant = cva(
  "border text-center p-4 text-sm flex items-center w-full justify-between",
  {
    variants: {
      variant: {
        default: "bg-gray-200 dark:bg-gray-500",
        warning: "bg-yellow-200 dark:bg-yellow-500",
        danger: "bg-red-200 dark:bg-red-500",
        success: "bg-emerald-200 dark:bg-emerald-500",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

interface BannerProps extends VariantProps<typeof bannerVariant> {
  label: string;
  couseId?: string;
  isPublish?: boolean;
  isVerified?: boolean;
}

const iconMap = {
  default: AlertCircle,
  warning: AlertTriangle,
  danger: FileWarning,
  success: CheckCircleIcon,
};

export const Banner = ({ label, variant, couseId, isPublish, isVerified }: BannerProps) => {
  const Icon = iconMap[variant || "default"];
  return (
    <div className={cn(bannerVariant({ variant }))}>
      <div className="flex items-center">
        <Icon className="h-4 w-4 mr-2" />
        <span>{label}</span>
      </div>

      {!isVerified && (
        // <Button className="bg-black hover:bg-gray-500 text-white hover:text-black">
        //   Publish
        // </Button>
        <ChapterActions disabled={false} courseId={couseId ?? ''} isPublished={isPublish ?? false} />
      )}
    </div>
  );
};
