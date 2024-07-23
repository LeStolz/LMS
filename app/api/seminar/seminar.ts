"use server";

import { db } from "@/lib/db";

export async function updateCourseSubtitle({
  subtitle,
  id,
}: {
  subtitle: string;
  id: number;
}) {
  console.log("got request");

  try {
    (await db())
      .input("subtitle", subtitle)
      .input("id", id)
      .execute("updateCourseSubtitle");
  } catch (error) {
    throw error;
  }
}

export async function searchCourse({ title }: { title: string }) {
  try {
    (await db()).input("title", title).execute("searchCourse");
  } catch (error) {
    throw error;
  }
}
