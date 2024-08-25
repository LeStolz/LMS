"use server";

import { db } from "@/lib/db";
import { authorize } from "../user/user";
import {
  Course,
  CourseCategories,
  CourseDetails,
  CourseEssentials,
  CourseSection,
} from "@/types/course";
import exp from "constants";
import { getCourse } from "./[courseId]/route";

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

export async function deleteCourse({ id }: { id: number }) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course = (
      await (await db()).input("id", id).execute("deleteCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchCourseByOwner() {
  const user = await authorize(["LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title", "")
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", "[]")
        .input("lecturerId", user.id)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", "C")
        .execute("searchCourses")
    ).recordset;

    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchCourseByCategory({
  categoryList,
}: {
  categoryList: any[];
}) {
  const user = await authorize(["LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title", "")
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", categoryList)
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", "C")
        .execute("searchCourses")
    ).recordset;
    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchAllCourse() {
  const user = await authorize(["LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course[] = (
      await (await db())
        .input("title", "")
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", "[]")
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", "C")
        .execute("searchCourses")
    ).recordset;
    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchVerifyCourse(): Promise<
  (Course & CourseCategories & CourseSection)[]
> {
  const user = await authorize(["LN"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let courses = (
      await (await db())
        .input("title", "")
        .input("status", "V")
        .input("offset", 0)
        .input("categoryIds", "[]")
        .input("lecturerId", null)
        .input("learnerId", null)
        .input("learningStatus", null)
        .input("orderBy", "C")
        .execute("searchCourses")
    ).recordset as any[];

    const detailedCourses = await Promise.all(
      courses.map(async (course) => {
        return await getCourse({
          id: course.id,
          withCategories: true,
          withSections: true,
          withReviews: true,
        });
      })
    );

    return detailedCourses;
  } catch (error) {
    throw error;
  }
}

export async function searchEnrollCourse({
  learningStatus,
}: {
  learningStatus: string;
}): Promise<(Course & CourseCategories & CourseSection)[]> {
  const user = await authorize(["LN"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const courses: Course[] = (
      await (await db())
        .input("title", "")
        .input("status", null)
        .input("offset", 0)
        .input("categoryIds", "[]")
        .input("lecturerId", null)
        .input("learnerId", user.id)
        .input("learningStatus", learningStatus)
        .input("orderBy", "C")
        .execute("searchCourses")
    ).recordset;

    const detailedCourses = await Promise.all(
      courses.map(async (course) => {
        return await getCourse({
          id: course.id,
          withCategories: true,
          withSections: true,
          withReviews: true,
        });
      })
    );

    return detailedCourses;
  } catch (error) {
    throw error;
  }
}

export async function verifyCourse({
  id,
  status,
  verifierId,
  notificationTitle,
  notificationContent,
}: {
  id: number;
  status: string;
  verifierId: number;
  notificationTitle: string;
  notificationContent: string;
}) {
  const user = await authorize(["AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course = (
      await (await db())
        .input("id", id)
        .input("status", status)
        .input("verifierId", verifierId)
        .input("notificationTitle", notificationTitle)
        .input("notificationContent", notificationContent)
        .execute("verifyCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}

export async function searchCourseAnnouncement({
  id,
  offset,
}: {
  id: number;
  offset: number;
}) {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course = (
      await (await db())
        .input("id", id)
        .input("offset", offset)
        .execute("searchCourseAnnouncement")
    ).recordset;

    return course;
  } catch (error) {
    throw error;
  }
}
