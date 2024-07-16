"use server";

import { User, UserWithPassword } from "@/types/user";
import { redirect } from "next/navigation";
import { insertUser, selectUser, selectUserByCred } from "./db";
import { encrypt, getSessionEmail } from "../auth/auth";
import { cookies } from "next/headers";
import { formatError } from "@/lib/utils";

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

async function setCredentialCookie(formData: FormData) {
  const expires = new Date(Date.now() + expiresDuration);
  const session = await encrypt({ email: formData.get("email"), expires });

  cookies().set("session", session, { expires, httpOnly: true });
}

export async function signIn(_currentState: unknown, formData: FormData) {
  authorize([null]);

  let isValidCredential = false;

  try {
    const user = await selectUserByCred(
      formData.get("email") as string,
      formData.get("password") as string
    );

    if (!user) {
      return "Invalid email or password.";
    }

    setCredentialCookie(formData);

    isValidCredential = true;
  } catch (error) {
    return formatError(error);
  } finally {
    if (isValidCredential) {
      redirect("/");
    }
  }
}

export async function signUp(_currentState: unknown, formData: FormData) {
  authorize([null]);

  let isValidCredential = false;

  try {
    const user: UserWithPassword = {
      email: formData.get("email")?.toString()!,
      password: formData.get("password")?.toString()!,
      name: formData.get("name")?.toString()!,
      type: formData.get("type")?.toString()! as User["type"],
    };

    await insertUser(user);

    setCredentialCookie(formData);

    isValidCredential = true;
  } catch (error) {
    return formatError(error);
  } finally {
    if (isValidCredential) {
      redirect("/");
    }
  }
}
