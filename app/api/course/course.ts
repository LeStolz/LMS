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

export async function getCourse<B extends boolean>({
  id,
  withCategories,
}: {
  id: number;
  withCategories: B;
}): Promise<B extends true ? Course & CourseCategories : Course> {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  console.log("User", user.id);

  try {
    let course = (
      await (await db())
        .input("id", id)
        .input("withCategories", withCategories)
        .input("withOwners", false)
        .input("withSections", false)
        .input("withDescriptionDetails", false)
        .input("withReviews", false)
        .input("learnerId", false)
        .execute("selectCourse")
    ).recordset?.[0];

    if(course.categories === null) {
      course.categories = [];
    }
    else{
      course.categories = JSON.parse(course.categories).filter(
        (category: Object) => category.hasOwnProperty("id")
      );

    }

    return course as B extends true ? Course & CourseCategories : Course;
  } catch (error) {
    throw error;
  }
}




export async function updateCourse({
  id,
  title,
  subtitle,
  description,
  price,
  level,
  thumbnail,
  advertisementVideo,
  updatedAt,
  categoryIds,
}: CourseEssentials & { categoryIds: number[] }) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course = (
      await (await db())
        .input("id", id)
        .input("title", title)
        .input("subtitle", subtitle)
        .input("description", description)
        .input("price", price)
        .input("level", level)
        .input("thumbnail", thumbnail)
        .input("advertisementVideo", advertisementVideo)
        .input("updatedAt", updatedAt)
        .input("categoryIds", JSON.stringify(categoryIds))
        .execute("updateCourse")
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
  const user = await authorize(["LT"]);

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