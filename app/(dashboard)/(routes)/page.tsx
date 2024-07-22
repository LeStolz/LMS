"use client";

import { useAuth } from "@/providers/auth-provider";
import { LoaderCircleIcon } from "lucide-react";

export default function Home() {
  const { user } = useAuth();

  return (
    <>
      {user.isLoading ? (
        <LoaderCircleIcon className="animate-spin" />
      ) : user.isError ? (
        <p>{user.error.message}</p>
      ) : user.data ? (
        <>
          <p>{user.data.email}</p>
          <p>{user.data.name}</p>
          <p>{user.data.type}</p>
        </>
      ) : (
        <p>Bad</p>
      )}
    </>
  );
}
