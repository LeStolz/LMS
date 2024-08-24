import { LucideIcon } from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";
import exp from "constants";

const backgroundVariants = cva(
  "rounded-full flex items-center justify-center",
  {
    variants: {
      variant: {
        default: "bg-gray-200 dark:bg-gray-700",
        success: "bg-emerald-200 dark:bg-emerald-700",
      },
      iconVariant: {
        default: "text-gray-500 dark:text-gray-300",
        success: "text-emerald-500 dark:text-emerald-300",
      },
      size: {
        default: "p-2",
        sm: "p-1",
      },
    },
    defaultVariants: {
      variant: "default",
      iconVariant: "default",
      size: "default",
    },
  }
);

const iconVariants = cva("", {
  variants: {
    variant: {
      default: "text-gray-500 dark:text-gray-300",
      success: "text-emerald-500 dark:text-emerald-300",
    },
    size: {
      default: "h-8 w-8",
      sm: "h-4 w-4",
    },
  },
  defaultVariants: {
    variant: "success",
    size: "default",
  },
});

type BackgroundVariants = VariantProps<typeof backgroundVariants>;
type IconVariants = VariantProps<typeof iconVariants>;

interface IconBadgeProps extends BackgroundVariants, IconVariants {
  icon: LucideIcon;
}

export default function IconBadge({
  icon: Icon,
  variant,
  size,
}: IconBadgeProps) {
  return (
    <div className={cn(backgroundVariants({ variant, size }))}>
      <Icon className={cn(iconVariants({ variant, size }))} />
    </div>
  );
}
