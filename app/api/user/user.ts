"use server";

import { User, UserWithPassword } from "@/types/user";
import { insertUser, selectUser, selectUserByCred } from "./db";
import { encrypt, getSessionEmail } from "../auth/auth";
import { cookies } from "next/headers";

const expiresDuration = parseInt(process.env.JWT_EXPIRES_IN_SECONDS!);

export async function getSession() {
  const sessionEmail = await getSessionEmail();
  return sessionEmail ? await selectUser(sessionEmail) : null;
}

export async function authorize(rolesAuthorized: (User["type"] | null)[]) {
  const session = await getSession();

  if (!rolesAuthorized.includes(session?.type ?? null)) {
    throw new Error("Unauthorized access.");
  }

  return session;
}

async function setCredentialCookie(email: string) {
  const expires = new Date(Date.now() + expiresDuration);
  const session = await encrypt({ email: email, expires });

  cookies().set("session", session, { expires, httpOnly: true });
}

export async function signIn(email: string, password: string) {
  authorize([null]);

  try {
    const user = await selectUserByCred(email, password);

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
  authorize([null]);

  try {
    await insertUser(user);

    setCredentialCookie(user.email);

    return user;
  } catch (error) {
    throw error;
  }
}
