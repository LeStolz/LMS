"use client";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import {
  searchCourseByOwner,
  searchCourseTitle,
  searchEnrollCourse,
  searchVerifyCourse,
} from "@/app/api/course/course";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { CourseList } from "./course-list";

export default function SearchData({ user }: { user: any }) {
  const searchParams = useSearchParams();
  const title = searchParams.get("title");
  const [data, setData] = useState<any>([]);
  const [attendedCourses, setAttendedCourses] = useState<any>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log("title", title);
        const result = await searchCourseTitle({ title: title || "" });
        setData(result);
      } catch {
        redirect("/");
      }

      try {
        const fecth = await searchEnrollCourse({
          learningStatus: "F",
        });
        setAttendedCourses(fecth);
      } catch {
        redirect("/");
      }
    };

    fetchData();
  }, [title]);

  const attendedCourseIds = new Set(
    attendedCourses?.map((course: any) => course.id) || []
  );
  const notAttendedCourses = data.filter(
    (course: any) => !attendedCourseIds.has(course.id)
  );

  return (
    <>
      <div className="p-6">
        <CourseList items={notAttendedCourses} user={user} />
      </div>
    </>
  );
}
