import { Button } from "@/components/ui/button";
import { DataTable } from "./_components/data-table";
import { columns } from "./_components/column";

import Link from "next/link";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import {
  searchCourseByOwner,
  searchCourseTitle,
  searchVerifyCourse,
} from "@/app/api/course/course";
import { SearchBar } from "../browse/_components/search-bar";
import SearchData from "./_components/search-data";

export default async function Component() {
  let data;

  try {
    data = await searchCourseTitle({
      title: "",
    });
  } catch {
    return redirect("/");
  }

  return (
    <>
      <div className="p-6">
        <SearchBar />
      </div>
      <main className="space-y-8">
        <SearchData />
      </main>
    </>
  );
}
