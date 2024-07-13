import { getSession } from "@/app/api/auth/auth";

export default async function Dashboard() {
  const session = await getSession();
  const userRole = session?.user?.role;

  if (userRole === "admin") {
    return <p>Admin</p>;
  } else if (userRole === "user") {
    return <p>User</p>;
  } else if (userRole === "lecturer") {
    return <p>Lecturer</p>;
  }
  return <p>Guest</p>;
}
