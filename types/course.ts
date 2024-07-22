export type Course = {
  id: number;
  title: string;
  subtitle: string;

  description?: string;
  price?: number;
  level?: "B" | "I" | "A";
  thumbnail?: string;
  advertisementVideo?: string;
  status: "C" | "R" | "P" | "V";
  createdAt: Date;
  visitorCount: number;
  rating: number;
  raterCount: number;
  learnerCount: number;
  lecturerCount: number;
  minutesToComplete: number;
  updatedAt: Date;
  monthlyRevenueGenerated: number;
};
