"use client";
import {
  Course,
  CourseCategories,
  CourseEssentials,
  CourseDetails,
  CourseSection,
  CourseChat,
} from "@/types/course";
import { CourseItems } from "./course-items";

interface CourseListProps {
    // items: (Course &
    //     CourseCategories &
    //     CourseEssentials &
    //     CourseDetails &
    //     CourseSection &
    //     CourseChat)[] | any[];
    items: any[];
    user: any;
}

export const CourseList = ({ items, user }: CourseListProps) => {

  console.log(items);
  return (
    <div>
      <div className="grid sm:grid-cols-2 md:grod-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-4 gap-4">
        {items.map((item) => (
          <CourseItems
            key={item.id}
            id={item.id}
            title={item.title}
            image={item.thumbnail || ""}
            sections={item.sections}
            price={item.price}
            categories={item.categories}
            user={user}
          />
        ))}
      </div>
      {items.length === 0 && (
        <div className="text-center text-slate-400 dark:text-slate-600 py-8">
          No courses was found.
        </div>
      )}
    </div>
  );
};
