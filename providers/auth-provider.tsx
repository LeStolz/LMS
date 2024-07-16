"use client";

import { signOut } from "@/app/api/auth/auth";
import { getSession } from "@/app/api/user/user";
import { User } from "@/types/user";
import { createContext, useContext, useEffect, useState } from "react";

type AuthContextType = {
  user: User | null;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType>({
  user: null,
  signOut: async () => {},
});

export function useAuth() {
  return useContext(AuthContext);
}

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<AuthContextType["user"]>(() => null);

  useEffect(() => {
    (async () => {
      setUser(await getSession());
    })();
  }, []);

  const signOutWrapper = async () => {
    setUser(null);
    await signOut();
  };

  return (
    <AuthContext.Provider value={{ user, signOut: signOutWrapper }}>
      {children}
    </AuthContext.Provider>
  );
};
