import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";

export default function Component() {
  return (
    <>
      <div className="relative md:grow-0">
        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <Input
          type="search"
          placeholder="Search courses"
          className="w-full rounded-lg bg-background pl-8 md:w-96 lg:w-96"
        />
      </div>
      <div>Hi</div>
    </>
  );
}
