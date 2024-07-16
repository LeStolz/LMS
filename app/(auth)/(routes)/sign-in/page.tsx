"use client";

import { useFormState, useFormStatus } from "react-dom";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { LoaderCircleIcon } from "lucide-react";
import { signIn } from "@/app/api/user/user";

export default function Component() {
  const [errorMessage, dispatch] = useFormState(signIn, null);

  return (
    <div className="flex min-h-screen items-center justify-center">
      <Card className="min-w-96 p-2">
        <CardHeader>
          <CardTitle>
            <h2 className="text-3xl font-bold">Sign in to your account</h2>
          </CardTitle>
          <CardDescription>Get started with LMS today.</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="space-y-6" action={dispatch}>
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                name="email"
                placeholder="Enter your email"
                required
              />
            </div>
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                name="password"
                placeholder="Enter your password"
                required
              />
            </div>
            {errorMessage && (
              <div>
                <p className="text-sm text-destructive">{errorMessage}</p>
              </div>
            )}
            <SubmitButton>Sign in</SubmitButton>
          </form>
        </CardContent>
        <CardFooter>
          <div className="text-center text-sm text-muted-foreground">
            Don't have an account?{" "}
            <Link
              href="/sign-up"
              className="font-medium underline underline-offset-2"
              prefetch={false}
            >
              Sign up
            </Link>
          </div>
        </CardFooter>
      </Card>
    </div>
  );
}

function SubmitButton({ children }: { children: string }) {
  const { pending } = useFormStatus();

  const handleClick = (event: any) => {
    if (pending) {
      event.preventDefault();
    }
  };

  return (
    <Button
      type="submit"
      className="w-full"
      aria-disabled={pending}
      onClick={handleClick}
    >
      {pending ? <LoaderCircleIcon className="animate-spin" /> : children}
    </Button>
  );
}
