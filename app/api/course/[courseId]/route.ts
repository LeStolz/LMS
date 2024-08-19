"use server";

import { db } from "@/lib/db";
import { authorize } from "../../user/user";
import { Course, CourseCategories, CourseDetails, CourseEssentials, CourseSection } from "@/types/course";
import exp from "constants";
import { comma } from "postcss/lib/list";

export async function getCourse<B extends boolean>({
  id,
  withCategories,
  withSections
}: {
  id: number;
  withCategories: B;
    withSections: B;

}): Promise<B extends true ? Course & CourseCategories & CourseSection : Course> {
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
        .input("withSections", withSections)
        .input("withDescriptionDetails", false)
        .input("withReviews", false)
        .input("learnerId", false)
        .execute("selectCourse")
    ).recordset?.[0];

    if (course.categories === null) {
      course.categories = [];
    } else {
      course.categories = JSON.parse(course.categories).filter(
        (category: Object) => category.hasOwnProperty("id")
      );
    }

    if (course.sections === null) {
      course.sections = [];
    } else {
      course.sections = JSON.parse(course.sections).filter((section: Object) =>
        section.hasOwnProperty("id")
      );
    }

    // if (course.descriptionDetails === null) {
    //   course.descriptionDetails = null;
    // } else {
    //   course.descriptionDetails = JSON.parse(course.descriptionDetails).filter(
    //     (descriptionDetails: Object) => descriptionDetails.hasOwnProperty("id")
    //   );
    // }

    return course as B extends true ? Course & CourseCategories & CourseSection : Course;
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

export async function insertCourseSection({
  courseId,
  title,
  description,
  pos,
} : {
  courseId: number;
  title: string;
  description?: string;
  pos: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("courseId", courseId)
        .input("title", title)
        .input("description", description)
        .input("pos", pos)
        .execute("insertCourseSection")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function updateCourseSection({
  id,
  courseId,
  title,
  description,
  pos,
}: {
  id: number;
  courseId: number;
  title: string;
  description?: string;
  pos: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  console.log('sectionId : ', id);
  console.log('courseId : ', courseId);
  console.log('title : ', title);
  console.log('description : ', description);
  console.log('pos : ', pos);

  try {
    const section = (
      await (await db())
        .input("id", id)
        .input("courseId", courseId)
        .input("title", title)
        .input("description", description)
        .input("pos", pos)
        .execute("updateCourseSection")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function deleteCourseSection({
  id,
  courseId,
}: {
  id: number;
  courseId: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("id", id)
        .input("courseId", courseId)
        .execute("deleteCourseSection")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

