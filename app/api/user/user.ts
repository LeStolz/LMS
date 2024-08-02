"use server";

import { User, UserWithDetails, UserWithPassword } from "@/types/user";
import { encrypt, getSessionEmail } from "../auth/auth";
import { cookies } from "next/headers";
import { db } from "@/lib/db";

const expiresDuration = parseInt(process.env.JWT_EXPIRES_IN_SECONDS!);

export async function getSession(withDetails = false) {
  const sessionEmail = await getSessionEmail();

  console.log(sessionEmail);

  return sessionEmail ? await getUser(sessionEmail, withDetails) : null;
}

export async function authorize(
  rolesAuthorized: (User["type"] | null)[],
  withDetails = false
) {
  const session = await getSession(withDetails);

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

export async function getUser(email: string, withDetails = false) {
  try {
    let user:
      | (UserWithDetails & {
          certificates: string | null;
          workExperiences: string | null;
        })
      | null =
      (
        await (await db())
          .input("email", email)
          .input("withDetails", withDetails)
          .execute("selectUser")
      ).recordset?.[0] ?? null;

    if (user?.certificates) {
      user.certificates = JSON.parse(user.certificates);
    }

    if (user?.workExperiences) {
      user.workExperiences = JSON.parse(user.workExperiences);
    }

    return user;
  } catch (error) {
    throw error;
  }
}

export async function demandLecturerVerification({ email }: { email: string }) {
  try {
    await (await db())
      .input("email", email)
      .execute("demandLecturerVerification");
  } catch (error) {
    throw error;
  }
}

export async function updateUser(
  user: UserWithDetails & { oldPassword: string }
) {
  try {
    await (await db())
      .input("email", user.email)
      .input("oldPassword", user.oldPassword)
      .input("password", user.password)
      .input("name", user.name)
      .execute("updateUser");

    if (user.type != "AD") {
      await (
        await db()
      )
        .input("email", user.email)
        .input("oldPassword", user.password)
        .input("name", user.name)
        .input("type", user.type)
        .input("accountNumber", user.accountNumber ?? "")
        .input("goodThru", user.goodThru ?? "")
        .input("cvc", user.cvc ?? "")
        .input("cardholderName", user.cardholderName ?? "")
        .input("zip", user.zip ?? "")
        .execute("updateUserAndBankAccount");
    }

    if (user.type == "LT") {
      await (
        await db()
      )
        .input("email", user.email)
        .input("oldPassword", user.password)
        .input("name", user.name)
        .input("type", user.type)
        .input("accountNumber", user.accountNumber ?? "")
        .input("goodThru", user.goodThru ?? "")
        .input("cvc", user.cvc ?? "")
        .input("cardholderName", user.cardholderName ?? "")
        .input("zip", user.zip ?? "")
        .input("dob", user.dob ?? "")
        .input("gender", user.gender ?? "")
        .input("homeAddress", user.homeAddress ?? "")
        .input("workAddress", user.workAddress ?? "")
        .input("nationality", user.nationality ?? "")
        .input("phone", user.phone ?? "")
        .input("introduction", user.introduction ?? "")
        .input("annualIncome", user.annualIncome ?? "")
        .input("academicRank", user.academicRank ?? "")
        .input("academicDegree", user.academicDegree ?? "")
        .input("profileImage", user.profileImage ?? "")
        .input("certificates", JSON.stringify(user.certificates) ?? "")
        .input("workExperiences", JSON.stringify(user.workExperiences) ?? "")
        .execute("updateLecturer");
    }
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
