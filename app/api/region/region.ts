"use server";

import { db } from "@/lib/db";
import { authorize } from "../user/user";
import { Region } from "@/types/region";

export async function searchRegion({ name }: { name: string }) {

  try {
    let region = (
      await (await db()).input("name", name).execute("searchRegions")
    ).recordset;

    return region as Region[];
  } catch (error) {
    throw error;
  }
}
