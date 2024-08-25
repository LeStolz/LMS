"use client"

import { cn } from "@/lib/utils";
import { Category } from "@/types/category";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { IconType } from "react-icons/lib";
import qs from "query-string"

interface CategoryItemsProps {
    label: string;
    value?: string | number;
    icon?: IconType;
}

export const CategoryItems = ({ label, value, icon: Icon }: CategoryItemsProps) => {
    const pathName = usePathname();
    const router = useRouter();
    const searchParams = useSearchParams();

    const currentCategoryId= searchParams.get("categoryId");
    const currentTitle = searchParams.get("title");
    const isSelected = Number(currentCategoryId) === value;

    const onClick = () => {
        const url = qs.stringifyUrl({
            url: pathName,
            query: {
                title: currentTitle,
                categoryId: isSelected ? undefined : value,
            }
        }, {skipNull: true, skipEmptyString: true});

        router.push(url);
    }


    return (
        <button onClick={onClick} type="button" className={cn(
            "py-2 px-3 text-sm border borde-slate-200 dark:border-slate-800",
            "rounded-full flex items-center gap-x-2",
            "hover:bg-sky-50 dark:hover:bg-slate-800 transition",
            isSelected && "border-sky-700 dark:border-sky-300 bg-sky-200/20 dark:bg-sky-900 text-sky-800 dark:text-sky-100"
        )}>
            {Icon && <Icon size={20} />}
            <div className="truncate">
                {label}
            </div>
        </button>
    )
}