import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatError(error: unknown) {
  if (error instanceof Error) {
    const message = error.message.split("'")[1];
    const type = message.split("_")[0];
    const table = message.split("_")[1];

    if (type === "pk") {
      return `This ${table} already exists`;
    }

    return message;
  }

  return "Something went wrong. Please try again later";
}
