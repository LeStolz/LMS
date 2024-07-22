"use server";

import { db } from "@/lib/db";
import { authorize } from "../user/user";
import { Course } from "@/types/course";

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
    const course: Course = (
      await (await db())
        .input("title", title)
        .input("subtitle", subtitle)
        .input("ownerEmail", user.email)
        .execute("insertCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}

export async function getCourse({ id }: { id: number }) {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course: Course = (
      await (await db()).input("id", id).execute("selectCourse")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}
