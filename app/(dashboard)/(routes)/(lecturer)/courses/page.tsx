import { Button } from "@/components/ui/button";
import Link from "next/link";

export default function Component() {
  return (
    <>
      <Link href="courses/new">
        <Button>New course</Button>
      </Link>
    </>
  );
}
