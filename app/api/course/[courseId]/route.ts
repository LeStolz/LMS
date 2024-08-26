"use server";

import { db } from "@/lib/db";
import { authorize } from "../../user/user";
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

const mux = new Mux({
  tokenId: process.env.MUX_TOKEN_ID,
  tokenSecret: process.env.MUX_TOKEN_SECRET,
});
export async function getCourse<B extends boolean>({
  id,
  withCategories,
  withSections,
  withReviews,
}: {
  id: number;
  withCategories: B;
  withSections: B;
  withReviews: B;
}): Promise<any> {
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
        .input("withReviews", withReviews)
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

    if (course.reviews === null) {
      course.reviews = [];
    } else {
      course.reviews = JSON.parse(course.reviews).filter((review: Object) =>
        review.hasOwnProperty("learnerId")
      );
    }

    // if (course.descriptionDetails === null) {
    //   course.descriptionDetails = null;
    // } else {
    //   course.descriptionDetails = JSON.parse(course.descriptionDetails).filter(
    //     (descriptionDetails: Object) => descriptionDetails.hasOwnProperty("id")
    //   );
    // }

    return course as any;
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
}: {
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

  console.log("sectionId : ", id);
  console.log("courseId : ", courseId);
  console.log("title : ", title);
  console.log("description : ", description);
  console.log("pos : ", pos);

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

export async function insertCourseLesson({
  courseId,
  pos,
  title,
  description,
  isFree,
  durationInMinutes,
}: {
  courseId: number;
  title: string;
  description?: string;
  pos: number;
  isFree: boolean;
  durationInMinutes: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("courseId", courseId)
        .input("pos", pos)
        .input("title", title)
        .input("description", description)
        .input("isFree", isFree)
        .input("durationInMinutes", durationInMinutes)
        .execute("insertCourseLesson")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function updateCourseLesson({
  id,
  courseId,
  title,
  description,
  pos,
  isFree,
  durationInMinutes,
}: {
  id: number;
  courseId: number;
  title: string;
  description?: string;
  pos: number;
  isFree: boolean;
  durationInMinutes: number;
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
        .input("title", title)
        .input("description", description)
        .input("pos", pos)
        .input("isFree", isFree)
        .input("durationInMinutes", durationInMinutes)
        .execute("updateCourseLesson")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function insertCourseExercise({
  courseId,
  pos,
  title,
  description,
  type,
}: {
  courseId: number;
  title: string;
  description?: string;
  pos: number;
  type?: "E" | "Q";
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("courseId", courseId)
        .input("pos", pos)
        .input("title", title)
        .input("description", description)
        .input("type", type)
        .execute("insertCourseExercise")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function insertCourseQuiz({
  courseId,
  pos,
  title,
  description,
  durationInMinutes,
}: {
  courseId: number;
  title: string;
  description?: string;
  pos: number;
  durationInMinutes: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("courseId", courseId)
        .input("pos", pos)
        .input("title", title)
        .input("description", description)
        .input("durationInMinutes", durationInMinutes)
        .execute("insertCourseQuiz")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function updateCourseQuiz({
  id,
  courseId,
  title,
  description,
  pos,
  durationInMinutes,
}: {
  id: number;
  courseId: number;
  title: string;
  description?: string;
  pos: number;
  isFree: boolean;
  durationInMinutes: number;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  console.log("sectionId : ", id);
  console.log("courseId : ", courseId);
  console.log("title : ", title);
  console.log("description : ", description);
  console.log("pos : ", pos);

  try {
    const section = (
      await (await db())
        .input("id", id)
        .input("courseId", courseId)
        .input("title", title)
        .input("description", description)
        .input("pos", pos)
        .input("durationInMinutes", durationInMinutes)
        .execute("updateCourseQuiz")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function insertCourseExerciseSolutionFile({
  id,
  courseSectionId,
  courseId,
  path,
  name,
}: {
  courseId: number;
  courseSectionId: number;
  id: number;
  path: string;
  name: string;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db())
        .input("courseId", courseId)
        .input("courseSectionId", courseSectionId)
        .input("id", id)
        .input("path", path)
        .input("name", name)
        .execute("insertCourseExerciseSolutionFile")
    ).recordset?.[0];

    return section;
  } catch (error) {
    throw error;
  }
}

export async function insertCourseSectionFile({
  courseSectionId,
  courseId,
  path,
  name,
  isVideo,
}: {
  courseSectionId: number;
  courseId: number;
  path: string;
  name: string;
  isVideo?: boolean;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    let section;
    if (isVideo) {
      const asset = await mux.video.assets.create({
        input: [{ url: path }],
        playback_policy: ["public"],
        encoding_tier: "baseline",
      });

      let concat = name + "|" + asset.playback_ids?.[0]?.id;
      section = (
        await (await db())
          .input("id", null)
          .input("courseId", courseId)
          .input("courseSectionId", courseSectionId)
          .input("path", path)
          .input("name", concat)
          .execute("insertCourseSectionFile")
      ).recordset?.[0];
    } else {
      section = (
        await (await db())
          .input("id", null)
          .input("courseId", courseId)
          .input("courseSectionId", courseSectionId)
          .input("path", path)
          .input("name", name)
          .execute("insertCourseSectionFile")
      ).recordset?.[0];
    }

    return section;
  } catch (error) {
    throw error;
  }
}

export async function deleteCourseSectionFile({
  id,
}: // assetId
{
  id: number;
  // assetId: string;
}) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const section = (
      await (await db()).input("id", id).execute("deleteCourseSectionFile")
    ).recordset?.[0];

    // await mux.video.assets.del(assetId);

    return section;
  } catch (error) {
    throw error;
  }
}

export async function enrollInCourse({
  courseId,
  couponId,
}: {
  courseId: number;
  couponId: number | null;
}) {
  const user = await authorize(["LN"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const enrollment = (
      await (await db())
        .input("courseId", courseId)
        .input("learnerId", user.id)
        .input("couponId", couponId)
        .execute("enrollInCourse")
    ).recordset?.[0];

    return enrollment;
  } catch (error) {
    throw error;
  }
}

export async function reviewCourse({
  courseId,
  rating,
  content,
}: {
  courseId: number;
  rating: number;
  content: string;
}) {
  const user = await authorize(["LN"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const review = (
      await (await db())
        .input("courseId", courseId)
        .input("learnerId", user.id)
        .input("rating", rating)
        .input("content", content)
        .execute("insertReview")
    ).recordset?.[0];

    return review;
  } catch (error) {
    throw error;
  }
}

export async function demandCourseVerification({ id }: { id: number }) {
  const user = await authorize(["LT"]);

  if (!user) {
    throw new Error("Unauthorized.");
  }

  try {
    const course = (
      await (await db()).input("id", id).execute("demandCourseVerification")
    ).recordset?.[0];

    return course;
  } catch (error) {
    throw error;
  }
}
