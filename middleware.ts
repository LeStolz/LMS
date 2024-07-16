import type { NextRequest } from "next/server";
import { updateSession } from "./app/api/auth/auth";

export async function middleware(request: NextRequest) {
  await updateSession(request);

  const currentUser = request.cookies.get("session")?.value;

  if (
    currentUser &&
    (request.nextUrl.pathname.startsWith("/sign-in") ||
      request.nextUrl.pathname.startsWith("/sign-up"))
  ) {
    return Response.redirect(new URL("/", request.url));
  }

  if (
    !currentUser &&
    !(
      request.nextUrl.pathname.startsWith("/sign-in") ||
      request.nextUrl.pathname.startsWith("/sign-up")
    )
  ) {
    return Response.redirect(new URL("/sign-in", request.url));
  }
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|.*\\.png$).*)"],
};
