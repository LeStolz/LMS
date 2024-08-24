"use server";

import { db } from "@/lib/db";
import { authorize } from "@/app/api/user/user";
import { Course, CourseCategories, CourseDetails, CourseEssentials, CourseSection } from "@/types/course";
import exp from "constants";
import { comma } from "postcss/lib/list";


export async function getSection({
    id,
    courseId,
  }: {
    id: number;
    courseId: number;
  }){

    console.log('id : ', id);

    const user = await authorize(["LN", "LT", "AD"]);

    if (!user) {
      throw new Error("Unauthorized.");
    }

    try {
      let section = (
        await (await db())
          .input("id", id)
          .input("courseId", courseId)
          .input("learnerId", null)
          .execute("selectCourseSection")
      ).recordset?.[0];

      return section;
    } catch (error) {
      console.log("Error in getSection : ", error);
      throw new Error("Failed to get section");
    }
  }