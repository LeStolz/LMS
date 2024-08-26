"use server";

import { User, UserWithDetails, UserWithPassword } from "@/types/user";
import { encrypt, getSessionId } from "../auth/auth";
import { cookies } from "next/headers";
import { db } from "@/lib/db";
import { Search } from "lucide-react";
import { searchRegion } from "../region/region";
import { Region } from "@/types/region";

const expiresDuration = parseInt(process.env.JWT_EXPIRES_IN_SECONDS!);

export async function getSession(withDetails = false) {
  const sessionId = await getSessionId();

  console.log(sessionId);

  return sessionId ? await getUser(sessionId, withDetails) : null;
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

async function setCredentialCookie(id: number) {
  const expires = new Date(Date.now() + expiresDuration);
  const session = await encrypt({ id: id, expires });

  cookies().set("session", session, { expires, httpOnly: true });
}

export async function getUser(id: number, withDetails = false) {
  try {
    let user:
      | (UserWithDetails & {
          certificates: string | null;
          workExperiences: string | null;
        })
      | null =
      (
        await (await db())
          .input("id", id)
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

export async function demandLecturerVerification({ id }: { id: number }) {
  try {
    await (await db()).input("id", id).execute("demandLecturerVerification");
  } catch (error) {
    throw error;
  }
}

export async function updateUser(
  user: Omit<UserWithDetails, "email"> & { oldPassword: string }
) {
  try {
    await (await db())
      .input("id", user.id)
      .input("oldPassword", user.oldPassword)
      .input("password", user.password)
      .input("name", user.name)
      .execute("updateUser");

    if (user.type != "AD") {
      if (typeof user.regionId !== "number") {
        user.regionId = Number(user.regionId);
      }

      await (
        await db()
      )
        .input("id", user.id)
        .input("type", user.type)
        .input("accountNumber", user.accountNumber ?? "")
        .input("goodThru", user.goodThru ?? "")
        .input("cvc", user.cvc ?? "")
        .input("cardholderName", user.cardholderName ?? "")
        .input("zip", user.zip ?? "")
        .input("regionId", user.regionId ?? "")
        .execute("updateUserAndBankAccount");
    }

    if (user.type == "LT") {
      await (
        await db()
      )
        .input("id", user.id)
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

    setCredentialCookie(user.id);

    return user;
  } catch (error) {
    throw error;
  }
}

export async function signUp(user: Omit<UserWithPassword, "id">) {
  await authorize([null]);

  try {
    const result: User = (
      await (await db())
        .input("email", user.email)
        .input("password", user.password)
        .input("name", user.name)
        .input("type", user.type)
        .execute("insertUser")
    ).recordset?.[0];

    setCredentialCookie(result.id);

    return result;
  } catch (error) {
    throw error;
  }
}

export async function selectLecturer({ status }: { status: string }) {
  try {
    const result = await (await db())
      .input("status", status)
      .execute("selectLecturer");
    return result.recordset;
  } catch (error) {
    throw error;
  }
}

export async function verifyLecturer({
  id,
  status,
  verifierId,
  notificationTitle,
  notificationContent,
}: {
  id: number;
  status: string;
  verifierId: number;
  notificationTitle: string;
  notificationContent: string;
}) {
  try {
    await (await db())
      .input("id", id)
      .input("status", status)
      .input("verifierId", verifierId)
      .input("notificationTitle", notificationTitle)
      .input("notificationContent", notificationContent)
      .execute("verifyLecturer");
  } catch (error) {
    throw error;
  }
}


export async function selectLecturerEarningPerMonth({
  id,
  year,
  month 
}: {
  id: number;
  year: number,
  month: number 
}) {
  try {
    const result = await (await db())
      .input("id", id)
      .input("date", new Date(`${year}-${month}-01`))
      .input("courseId", null)
      .execute("selectLecturerEarningPerMonthFixed");
    
    return result.recordset[0].count??0;
  } catch (error) {
    throw error;
  }
}