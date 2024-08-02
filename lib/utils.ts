import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatError(error: unknown) {
  if (error instanceof Error) {
    let pos1 = error.message.indexOf("'");
    let pos2 = error.message.indexOf('"');

    if (pos1 != -1 || pos2 != -1) {
      pos1 = pos1 == -1 ? Infinity : pos1;
      pos2 = pos2 == -1 ? Infinity : pos2;

      let delimiter = pos1 < pos2 ? "'" : '"';

      const message = error.message.split(delimiter)[1];

      if (message.includes("_")) {
        const type = message.split("_")[0];
        const table = message.split("_")[1];

        if (type === "pk") {
          return `This ${table} already exists.`;
        }
      }

      return message;
    }

    return error.message;
  }

  return "Something went wrong. Please try again later.";
}

export function toCapitalCase(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
