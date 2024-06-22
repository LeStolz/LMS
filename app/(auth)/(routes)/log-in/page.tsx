"use client";

import { authenticate } from "@/app/api/auth/log-in";
import { Button } from "@/components/ui/button";
import { useFormState, useFormStatus } from "react-dom";

export default function LogInPage() {
  const [error, dispatch] = useFormState(authenticate, undefined);

  return (
    <form action={dispatch}>
      <input type="email" name="email" placeholder="Email" required />
      <input type="password" name="password" placeholder="Password" required />
      <div>{error && <p>{error.body}</p>}</div>
      <LogInButton />
    </form>
  );
}

function LogInButton() {
  const { pending } = useFormStatus();

  return (
    <Button
      aria-disabled={pending}
      type="submit"
      onClick={(event) => {
        if (pending) {
          event.preventDefault();
        }
      }}
    >
      Log In
    </Button>
  );
}
