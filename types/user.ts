export type User = {
  email: string;
  name: string;
  type: "AD" | "LN" | "LT";
};

export type UserWithPassword = User & {
  password: string;
};
