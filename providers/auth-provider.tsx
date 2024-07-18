"use client";

import { signOut } from "@/app/api/auth/auth";
import { getSession, signIn, signUp } from "@/app/api/user/user";
import { formatError } from "@/lib/utils";
import { User, UserWithPassword } from "@/types/user";
import { useRouter } from "next/navigation";
import { createContext, useContext, useEffect, useState } from "react";

type AuthContextType = {
  user: User | null;
  signUp: (user: UserWithPassword) => Promise<string | undefined>;
  signIn: (email: string, password: string) => Promise<string | undefined>;
  signOut: () => Promise<string | undefined>;
};

const AuthContext = createContext<AuthContextType>({
  user: null,
  signUp: async () => undefined,
  signIn: async () => undefined,
  signOut: async () => undefined,
});

export function useAuth() {
  return useContext(AuthContext);
}

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<AuthContextType["user"]>(() => null);
  const router = useRouter();

  useEffect(() => {
    (async () => {
      setUser(await getSession());
    })();
  }, []);

  const signOutWrapper = async () => {
    try {
      setUser(null);
      await signOut();

      router.push("/sign-in");
    } catch (error) {
      return formatError(error);
    }
  };

  const signUpWrapper = async (user: UserWithPassword) => {
    try {
      await signUp(user);
      setUser(user);

      user && router.push("/");
    } catch (error) {
      return formatError(error);
    }
  };

  const signInWrapper = async (email: string, password: string) => {
    try {
      const user = await signIn(email, password);

      console.log(user);

      setUser(user);

      user && router.push("/");
    } catch (error) {
      return formatError(error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        signIn: signInWrapper,
        signUp: signUpWrapper,
        signOut: signOutWrapper,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
