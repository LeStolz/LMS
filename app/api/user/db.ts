"use server";

import { db } from "@/lib/db";
import { User, UserWithPassword } from "@/types/user";

export async function selectUser(email: string) {
  try {
    const user: User | null =
      (await (await db()).input("email", email).execute("selectUser"))
        .recordset?.[0] ?? null;

    return user;
  } catch (error) {
    throw error;
  }
}

export async function selectUserByCred(email: string, password: string) {
  try {
    const user: User | null =
      (
        await (await db())
          .input("email", email)
          .input("password", password)
          .execute("selectUserByCred")
      ).recordset?.[0] ?? null;

    return user;
  } catch (error) {
    throw error;
  }
}

export async function insertUser(user: UserWithPassword) {
  try {
    await (await db())
      .input("email", user.email)
      .input("password", user.password)
      .input("name", user.name)
      .input("type", user.type)
      .execute("insertUser");
  } catch (error) {
    throw error;
  }
}
