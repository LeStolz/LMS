import { searchCategories } from "@/app/api/category/category";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";
import Link from "next/link";
import { title } from "process";
import { Categories } from "./_components/categories";
import path from "path";
import { SearchBar } from "./_components/search-bar";
import { searchVerifyCourse } from "@/app/api/course/course";
import { CourseList } from "./_components/course-list";

export default async function Component() {
  const categories = await searchCategories({ title: "" });
  const course = await searchVerifyCourse();
  console.log(course);
  return (
    <>
      <div className="p-6">
        <Categories categories={categories} />
      </div>
      <div className="w-full mx-auto p-4">
        <SearchBar />
        <main className="space-y-8">
          <CourseList items={course} />
        </main>
      </div>
    </>
  );
}

function GlobeIcon(props: any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="10" />
      <path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20" />
      <path d="M2 12h20" />
    </svg>
  );
}

function UserIcon(props: any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  );
}
