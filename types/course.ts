import { Category } from "./category";

export type CourseEssentials = {
  id: number;
  title: string;
  subtitle: string;
  description?: string;
  price?: number;
  level?: "B" | "I" | "A";
  thumbnail?: string;
  advertisementVideo?: string;
  updatedAt: Date;
};

export type Course = CourseEssentials & {
  status: "C" | "R" | "P" | "V";
  createdAt: Date;
  visitorCount: number;
  rating: number;
  raterCount: number;
  learnerCount: number;
  lecturerCount: number;
  minutesToComplete: number;
  monthlyRevenueGenerated: number;
};

export type CourseCategories = {
  categories: Category[];
};

export type CourseFile = {
  id: number;
  url: string;
  type: "V" | "D";
};
