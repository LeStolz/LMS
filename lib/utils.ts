import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatError(error: unknown) {
  if (error instanceof Error) {
    if (error.message.includes("'")) {
      const message = error.message.split("'")[1];

      if (message.includes("_")) {
        const type = message.split("_")[0];
        const table = message.split("_")[1];

        if (type === "pk") {
          return `This ${table} already exists`;
        }
      }

      return message;
    }

    return error.message;
  }

  return "Something went wrong. Please try again later";
}

export function toCapitalCase(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
