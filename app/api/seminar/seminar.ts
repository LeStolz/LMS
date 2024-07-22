"use server";

import { db } from "@/lib/db";

export async function updateCourseSubtitle({
  subtitle,
  id,
}: {
  subtitle: string;
  id: number;
}) {
  try {
    (
      await (await db())
        .input("subtitle", subtitle)
        .input("id", id)
        .execute("updateCourseSubtitle")
    ).recordset?.[0] ?? null;
  } catch (error) {
    throw error;
  }
}

export async function searchCourse({ title }: { title: string }) {
  try {
    (await (await db()).input("title", title).execute("searchCourse"))
      .recordset?.[0] ?? null;
  } catch (error) {
    throw error;
  }
}
