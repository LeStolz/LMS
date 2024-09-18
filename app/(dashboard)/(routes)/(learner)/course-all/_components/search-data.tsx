"use client";
import { Button } from "@/components/ui/button";
import { DataTable } from "./data-table";
import { columns } from "./column";
import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import {
  searchCourseByOwner,
  searchCourseTitle,
  searchVerifyCourse,
} from "@/app/api/course/course";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";

export default function SearchData() {
  const searchParams = useSearchParams();
  const title = searchParams.get("title");
  const [data, setData] = useState<any>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log("title", title);
        const result = await searchCourseTitle({ title: title || "" });
        setData(result);
      } catch {
        redirect("/");
      }
    };

    fetchData();
  }, [title]);

  return (
    <>
      <div className="p-6">
        <DataTable columns={columns} data={data} />
      </div>
    </>
  );
}