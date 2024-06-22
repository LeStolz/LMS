"use server";

export async function authenticate(_currentState: unknown, formData: FormData) {
  try {
    const email = formData.get("email") as string;
    const password = formData.get("password") as string;

    if (!(await logIn(email, password))) {
      return {
        status: 401,
        body: "Invalid email or password.",
      };
    }

    return {
      status: 302,
      headers: {
        Location: "/dashboard",
      },
    };
  } catch (error) {
    return {
      status: 500,
      body: "Something went wrong. Please try again later.",
    };
  }
}

async function logIn(email: string, password: string) {
  return email === "email" && password === "password";
}
