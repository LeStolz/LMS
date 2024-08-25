import { Category } from "./category";
import { Chat } from "./chat";

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

export type CourseDetails = {
  content: string;
  type: "P"| "O" | "S" | "T" | "L";
}

export type Section = {
  id: number;
  pos : number;
  title: string;
  description?: string;
  type: "M" | "L" | "E";
  sectionFiles?: File[];
  lesson?: Lesson;
  exercise?: Exercise;
  sectionProgress?: SectionProgress;
}

export type CourseSection = {
  sections: Section [];
};

export type Lesson = {
  id: number;
  isFree: boolean;
  durationInMinutes: number;
};

export type Exercise = {
  id: number;
  type: "Q" | "E";
  exerciseSolutionFile?: File[];
  quizes?: Quiz[];
  exerciseProgress?: ExerciseProgress;
};

export type Answer = {
  answer: string;
  symbol: string;
};

export type Question = {
  id: number;
  question: string;
  answers: Answer[];
  correctAnswerSymbol: string;
};
export type Quiz = {
  id: number;
  questions: Question[];
  durationInMinutes: number;
};

export type File ={
  id : number;
  path : string;
  name : string;
}

export type SectionProgress = {
  learnerId: number;
  completionPercentage: Float64Array;
  type : "S" | "E"
};

export type ExerciseProgress = {
  learnerId: number;
  savedTextSolution: string;
  grade: Float64Array;
};

export type CourseChat = {
  chat: Chat[];
};