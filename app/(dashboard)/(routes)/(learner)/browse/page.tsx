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
import {
  searchEnrollCourse,
  searchVerifyCourse,
} from "@/app/api/course/course";
import { CourseList } from "./_components/course-list";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";

export default async function Component() {
  const categories = await searchCategories({ title: "" });
  const allCourses = await searchVerifyCourse();
  const attendedCourses = await searchEnrollCourse({ learningStatus: "F" });
  const attendedCourseIds = new Set(attendedCourses.map((course) => course.id));
  const notAttendedCourses = allCourses.filter(
    (course) => !attendedCourseIds.has(course.id)
  );

  console.log(notAttendedCourses);
  let user;

  try {
    user = await authorize(["LN"], true);
  } catch {
    return redirect("/");
  }

  if (!user) {
    return redirect("/");
  }

  return (
    <>
      <div className="p-6">
        <Categories categories={categories} />
      </div>
      <div className="w-full mx-auto p-4">
        <SearchBar />
        <main className="space-y-8">
          <CourseList items={notAttendedCourses} user={user} />
        </main>
      </div>
    </>
  );
}
