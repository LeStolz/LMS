"use client";

import { Category } from "@/types/category";
import {
  FcEngineering,
  FcFilmReel,
  FcGraduationCap,
  FcReadingEbook,
  FcSportsMode,
  FcVideoCall,
  FcVoicePresentation,
  FcMultipleDevices,
  FcConferenceCall,
  FcBusinessman,
  FcCollaboration,
} from "react-icons/fc";
import { IconType } from "react-icons/lib";
import { CategoryItems } from "./category-items";

interface CategoriesProps {
  categories: Category[];
}

const iconMap: Record<Category["title"], IconType> = {
  "Engineering": FcEngineering,
  "Film": FcFilmReel,
  "Education": FcGraduationCap,
  "Reading": FcReadingEbook,
  "Sports": FcSportsMode,
  "Video": FcVideoCall,
  "Voice": FcVoicePresentation,
  "Devices": FcMultipleDevices,
  "Conference": FcConferenceCall,
  "Business": FcBusinessman,
  "Collaboration": FcCollaboration,
};

export const Categories = ({ categories }: CategoriesProps) => {
  return (

    <div className="flex items-center gap-x-2 overflow-x-auto pb-2">
        {categories.map((category) => (
            <CategoryItems
            key={category.id}
            label={category.title}
            icon={iconMap[category.title]}
            value={category.id}
            />
        ))}
    </div>
  )
};
