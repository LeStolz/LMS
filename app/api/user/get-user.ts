"use server";

import { db } from "@/lib/db";
import { authorize } from "../auth/auth";
import { User } from "@/types/user";

export async function getUser() {
  const email = authorize(["admin", "lecturer", "learner"]);

  try {
    const user: User = {
      ...(
        await (await db())
          .input("email", email)
          .execute("SELECT * FROM users WHERE email = @email")
      ).recordset?.[0],
    };

    return {
      status: 200,
      body: user,
    };
  } catch (error) {
    return {
      status: 500,
    };
  }
}
