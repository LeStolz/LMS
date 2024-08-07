"use client";

import { signOut } from "@/app/api/auth/auth";
import { getSession, signIn, signUp } from "@/app/api/user/user";
import { formatError } from "@/lib/utils";
import { UserWithPassword } from "@/types/user";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";

export function useAuth() {
  const router = useRouter();
  const queryClient = useQueryClient();

  const user = useQuery({
    queryKey: ["user"],
    queryFn: () => getSession(),
  });

  const signUpMutation = useMutation({
    mutationFn: signUp,
    onSuccess: (data) => {
      queryClient.setQueryData(["user"], data);
    },
  });

  const signInMutation = useMutation({
    mutationFn: signIn,
    onSuccess: (data) => {
      queryClient.setQueryData(["user"], data);
    },
  });

  const signOutWrapper = async () => {
    try {
      await signOut();

      router.push("/sign-in");
    } catch (error) {
      return formatError(error);
    }
  };

  const signUpWrapper = async (user: Omit<UserWithPassword, "id">) => {
    try {
      await signUpMutation.mutateAsync(user);

      user && router.push("/");
    } catch (error) {
      return formatError(error);
    }
  };

  const signInWrapper = async (email: string, password: string) => {
    try {
      await signInMutation.mutateAsync({ email, password });

      user && router.push("/");
    } catch (error) {
      return formatError(error);
    }
  };

  return {
    user: user,
    signIn: signInWrapper,
    signUp: signUpWrapper,
    signOut: signOutWrapper,
  };
}
