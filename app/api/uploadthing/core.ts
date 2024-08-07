import { createUploadthing, type FileRouter } from "uploadthing/next";
import { authorize } from "../user/user";

const f = createUploadthing();

const auth = async () => {
  const userId = await authorize(["LT"]);

  if (!userId) {
    throw new Error("Unauthorized.");
  }

  return userId;
};

export const ourFileRouter = {
  courseThumbnail: f({
    image: { maxFileSize: "1MB", maxFileCount: 1 },
  })
    .middleware(() => auth())
    .onUploadComplete(() => {}),
  courseAdvertisementVideo: f({
    video: { maxFileSize: "2MB", maxFileCount: 1 },
  })
    .middleware(() => auth())
    .onUploadComplete(() => {}),
  courseSectionFile: f(["text", "image", "video", "audio", "pdf"])
    .middleware(() => auth())
    .onUploadComplete(() => {}),
  courseSectionVideo: f({ video: { maxFileSize: "2MB", maxFileCount: 1 } })
    .middleware(() => auth())
    .onUploadComplete(() => {}),

  profileCertImages: f(["image"])
    .middleware(() => auth())
    .onUploadComplete(() => {}),
  profileWorkImages: f(["image"])
    .middleware(() => auth())
    .onUploadComplete(() => {}),
} satisfies FileRouter;

export type OurFileRouter = typeof ourFileRouter;
