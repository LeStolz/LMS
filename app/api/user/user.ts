"use server";

import { User, UserWithPassword } from "@/types/user";
import { encrypt, getSessionEmail } from "../auth/auth";
import { cookies } from "next/headers";
import { db } from "@/lib/db";

const expiresDuration = parseInt(process.env.JWT_EXPIRES_IN_SECONDS!);

export async function getSession() {
  const sessionEmail = await getSessionEmail();
  return sessionEmail ? await getUser(sessionEmail) : null;
}

export async function authorize(rolesAuthorized: (User["type"] | null)[]) {
  const session = await getSession();

  if (!rolesAuthorized.includes(session?.type ?? null)) {
    throw new Error("Unauthorized.");
  }

  return session;
}

async function setCredentialCookie(email: string) {
  const expires = new Date(Date.now() + expiresDuration);
  const session = await encrypt({ email: email, expires });

  cookies().set("session", session, { expires, httpOnly: true });
}

export async function getUser(email: string) {
  try {
    const user: User | null =
      (await (await db()).input("email", email).execute("selectUser"))
        .recordset?.[0] ?? null;

    return user;
  } catch (error) {
    throw error;
  }
}

export async function signIn({
  email,
  password,
}: {
  email: string;
  password: string;
}) {
  await authorize([null]);

  try {
    const user: User | null =
      (
        await (await db())
          .input("email", email)
          .input("password", password)
          .execute("selectUserByCred")
      ).recordset?.[0] ?? null;

    if (!user) {
      throw new Error("Invalid email or password.");
    }

    setCredentialCookie(email);

    return user;
  } catch (error) {
    throw error;
  }
}

export async function signUp(user: UserWithPassword) {
  await authorize([null]);

  try {
    await (await db())
      .input("email", user.email)
      .input("password", user.password)
      .input("name", user.name)
      .input("type", user.type)
      .execute("insertUser");

    setCredentialCookie(user.email);

    return user;
  } catch (error) {
    throw error;
  }
}
