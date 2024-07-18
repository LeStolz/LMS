"use server";

import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";

const secretKey = process.env.JWT_KEY;
const key = new TextEncoder().encode(secretKey);
const expiresDuration = parseInt(process.env.JWT_EXPIRES_IN_SECONDS!);

export async function encrypt(payload: any) {
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(`${expiresDuration} sec from now`)
    .sign(key);
}

export async function decrypt(input: string) {
  const { payload } = await jwtVerify(input, key, {
    algorithms: ["HS256"],
  });

  return payload as { email: string; expires: Date };
}

export async function signOut() {
  cookies().delete("session");
}

export async function getSessionEmail() {
  const session = cookies().get("session")?.value;

  return session ? (await decrypt(session)).email : null;
}

export async function updateSession(request: NextRequest) {
  const session = request.cookies.get("session")?.value;

  if (!session) return;

  const parsed = await decrypt(session);

  parsed.expires = new Date(Date.now() + expiresDuration);

  const res = NextResponse.next();

  res.cookies.set({
    name: "session",
    value: await encrypt(parsed),
    httpOnly: true,
    expires: parsed.expires,
  });

  return res;
}
