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
    (await db())
      .input("subtitle", subtitle)
      .input("id", id)
      .execute("updateCourseSubtitle").catch((err) => {
        console.error("Error: Request timed out");
      })
  } catch (error) {
    if(error instanceof Error) {
      console.error("Error: Request timed out");
    }
  }
}

export async function searchCourse({ title }: { title: string }) {
  try {
    (await db()).input("title", title).execute("searchCourse").catch(error => {
      console.error("Error: Request timed out");
    })
  } catch (error) {
    if(error instanceof Error) {
      console.error("Error: Request timed out");
    }
  }
}
