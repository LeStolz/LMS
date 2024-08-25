"use server";

import { db } from "@/lib/db";
import { authorize } from "../user/user";
import { Course, CourseCategories, CourseEssentials } from "@/types/course";
import exp from "constants";


export async function createCourse({
  title,
  subtitle,
}: {
  title: string;
  subtitle: string;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    console.log("User id", user.id);
    const course: Course = (
      await (await db())
        .input("title", title)
        .input("subtitle", subtitle)
        .input("ownerId", user.id)
        .execute("insertCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}



export async function deleteCourse({
  id,
}: {
  id: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course = (
      await (await db())
        .input("id", id)
        .execute("deleteCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchCourseByOwner(){
  const user = await authorize(["LT" , "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title",'')
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", '[]')
        .input("lecturerId", user.id)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", 'C')
        .execute("searchCourses")
    ).recordset;

    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchCourseByCategory({categoryList} : {categoryList : any[]}){
  const user = await authorize(["LT" , "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title",'')
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", categoryList)
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", 'C')
        .execute("searchCourses")
    ).recordset;
    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchAllCourse(){
  const user = await authorize(["LT" , "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title",'')
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", '[]')
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", 'C')
        .execute("searchCourses")
    ).recordset;
    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchVerifyCourse(){
  const user = await authorize(["LN"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title",'')
        .input("status", 'V')
        .input("offset", 0)
        .input("categoryIds", '[]')
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", 'C')
        .execute("searchCourses")
    ).recordset;
    return course;
  } catch (error) {
    throw error;
  }
}





