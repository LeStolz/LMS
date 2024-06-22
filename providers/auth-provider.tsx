"use client";

import { getUser } from "@/app/api/user/get-user";
import { User } from "@/types/user";
import { useQuery } from "@tanstack/react-query";
import { createContext, useContext } from "react";

type AuthContextType = {
  user: User | null;
};

const AuthContext = createContext<AuthContextType>({
  user: null,
});

export function useAuth() {
  return useContext(AuthContext);
}

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const { data: user } = useQuery({
    queryKey: ["user"],
    queryFn: async () => {
      return (await getUser()).body;
    },
  });

  return (
    <AuthContext.Provider value={{ user }}>{children}</AuthContext.Provider>
  );
};
