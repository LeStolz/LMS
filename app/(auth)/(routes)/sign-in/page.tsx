"use client";

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
import { useAuth } from "@/providers/auth-provider";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useState } from "react";

const formSchema = z.object({
  email: z.string().email({
    message: "Invalid email address.",
  }),
  password: z.string().min(5, {
    message: "Password must be at least 5 characters long.",
  }),
});

export default function Component() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  });
  const { isSubmitting, isValid } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);

  const { signIn } = useAuth();

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setError(await signIn(values.email, values.password));
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <Card className="min-w-96 p-2">
        <CardHeader>
          <CardTitle>
            <span className="text-3xl font-bold">Sign in to your account</span>
          </CardTitle>
          <CardDescription>Get started with LMS today.</CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input
                        type="email"
                        placeholder="Enter your email"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Password</FormLabel>
                    <FormControl>
                      <Input
                        type="password"
                        placeholder="Enter your password"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <div>
                <Button
                  type="submit"
                  className="w-full"
                  aria-disabled={isSubmitting}
                  onClick={(event: any) => {
                    if (isSubmitting) {
                      event.preventDefault();
                    }
                  }}
                >
                  {isSubmitting ? (
                    <LoaderCircleIcon className="animate-spin" />
                  ) : (
                    "Sign in"
                  )}
                </Button>
                {error && <FormMessage className="pt-2">{error}</FormMessage>}
              </div>
            </form>
          </Form>
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
