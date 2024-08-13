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

  try {
    let course = (
      await (await db())
        .input("id", id)
        .input("withCategories", withCategories)
        .execute("selectCourse")
    ).recordset?.[0];

    course.categories = JSON.parse(course.categories).filter(
      (category: Object) => category.hasOwnProperty("id")
    );

    return course as B extends true ? Course & CourseCategories : Course;
  } catch (error) {
    throw error;
  }
}

export async function getCourseOwner({
  id,
}: {
  id: number;
}) {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let course = (
      await (await db())
        .input("id", id)
        .execute("getCoursesById")
    ).recordset[0];

    if (course.categories) {
      course.categories = JSON.parse(course.categories).filter(
      (category: Object) => category.hasOwnProperty("id")
      );
    } else {
      course.categories = [];
    }

    return course;
  } catch (error) {
    throw error;
  }
}


export async function getAllCourses() {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let courses = (
      await (await db()).execute("selectAllCourses")
    ).recordset;

    return courses;
  } catch (error) {
    throw error;
  }
}

export async function getCourseByOwner({
  ownerId,
}: {
  ownerId: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let courses = (
      await (await db())
        .input("ownerId", ownerId)
        .execute("selectCourseByOwner")
    ).recordset;

    return courses;
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
