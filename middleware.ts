import type { NextRequest } from "next/server";
import { updateSession } from "./app/api/auth/auth";

export async function middleware(request: NextRequest) {
  await updateSession(request);

  const currentUser = request.cookies.get("currentUser")?.value;

  if (currentUser && !request.nextUrl.pathname.startsWith("/dashboard")) {
    return Response.redirect(new URL("/dashboard", request.url));
  }

  if (
    !currentUser &&
    !(
      request.nextUrl.pathname.startsWith("/log-in") ||
      request.nextUrl.pathname.startsWith("/sign-in")
    )
  ) {
    return Response.redirect(new URL("/log-in", request.url));
  }
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|.*\\.png$).*)"],
};
