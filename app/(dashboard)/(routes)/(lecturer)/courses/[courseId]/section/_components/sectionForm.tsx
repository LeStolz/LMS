"use client";

import { FormProvider, useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { Form, FormMessage } from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { LoaderCircleIcon } from "lucide-react";
import Link from "next/link";
import { formatError } from "@/lib/utils";
import { toast } from "sonner";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Course,
  CourseCategories,
  CourseDetails,
  CourseSection,
} from "@/types/course";
import { useRouter } from "next/navigation";
import {
  insertCourseSection,
  updateCourse,
} from "@/app/api/course/[courseId]/route";
import SectionGeneral from "./sectionGeneral";

export default function Component({
  course,
}: {
  course: Course & CourseCategories & CourseSection;
}) {

  return (
    <Tabs defaultValue="section" className="w-full">
      <TabsList>
        <TabsTrigger value="section">Section</TabsTrigger>
        <TabsTrigger value="file">File</TabsTrigger>
      </TabsList>
      <TabsContent value="section">
        <SectionGeneral courseId={course.id} sections={course.sections} />
      </TabsContent>
      <TabsContent value="file">
        File
      </TabsContent>
    </Tabs>
  );
}
