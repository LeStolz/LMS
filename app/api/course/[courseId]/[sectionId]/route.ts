"use server";

import { db } from "@/lib/db";
import { authorize } from "@/app/api/user/user";
import {
  Course,
  CourseCategories,
  CourseDetails,
  CourseEssentials,
  CourseSection,
} from "@/types/course";
import exp from "constants";
import { comma } from "postcss/lib/list";
import Mux from "@mux/mux-node";
import { insertCourseSectionFile } from "../route";

// const { Video } = new Mux(
//   process.env.MUX_TOKEN_ID,
//   process.env.MUX_TOKEN_SECRET
// );

export async function findVideoSection({
  courseId,
  couseSectionId,
}: {
  courseId: number;
  couseSectionId: number;
}) {
  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let data = (
      await (await db())
        .input("courseId", courseId)
        .input("courseSectionId", couseSectionId)
        .execute("selectCourseSectionFile")
    ).recordset?.[0];

    return data.files;

    return data;
  } catch (error) {
    console.log("Error in getSection : ", error);
    throw new Error("Failed to get section");
  }
}

export async function getSection({
  id,
  courseId,
  learnerId,
}: {
  id: number;
  courseId: number;
  learnerId?: number | null;
}) {
  console.log("id : ", id);

  const user = await authorize(["LN", "LT", "AD"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }
  if (!learnerId) {
    learnerId = null;
  }

  try {
    let section = (
      await (await db())
        .input("id", id)
        .input("courseId", courseId)
        .input("learnerId", learnerId)
        .execute("selectCourseSection")
    ).recordset?.[0];

    let existingMuxData;
    // if(section.files){
    //   existingMuxData = await findVideoSection({
    //     courseId,
    //     couseSectionId: id,
    //   });
    // }

    // if(existingMuxData){
    //   await Video.Assets.del(existingMuxData.assetId);
    //   // await Video.Assets.del(existingMuxData.playbackId);
    // }

    // const asset = await Video.Assets.create({
    //   input: existingMuxData.url,
    //   playback_policy: "public",
    //   test: false,
    // });

    // await insertCourseSectionFile({
    //   courseId,
    //   courseSectionId: id,
    //   path: existingMuxData.url, // Assuming `existingMuxData.url` is the path
    //   name: existingMuxData.name // Replace with the actual name if available
    // })

    return section;
  } catch (error) {
    console.log("Error in getSection : ", error);
    throw new Error("Failed to get section");
  }
}
