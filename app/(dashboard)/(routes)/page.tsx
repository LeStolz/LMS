"use client";

import { useAuth } from "@/providers/auth-provider";

export default function Home() {
  const { user } = useAuth();

  return (
    <>
      <p>{user?.email}</p>
      <p>{user?.name}</p>
      <p>{user?.type}</p>
    </>
  );
}
