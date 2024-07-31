"use server";

import { db } from "@/lib/db";
import { authorize } from "../user/user";
import { Category } from "@/types/category";

export async function searchCategories({ title }: { title: string }) {
  await authorize(["LN", "LT", "AD"]);

  try {
    let categories = (
      await (await db()).input("title", title).execute("searchCategories")
    ).recordset;

    return categories as Category[];
  } catch (error) {
    throw error;
  }
}
