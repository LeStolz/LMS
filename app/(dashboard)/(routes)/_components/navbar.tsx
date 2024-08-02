import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { ThemeButton } from "@/components/ui/theme-button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";
import { useAuth } from "@/providers/auth-provider";
import {
  BookOpenTextIcon,
  Compass,
  Home,
  LineChart,
  List,
  User2,
  Users2,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Navbar() {
  const pathName = usePathname();
  const { user, signOut } = useAuth();

  const routes =
    user.data?.type === "LT"
      ? [
          {
            icon: <Home className="h-5 w-5" />,
            label: "Dashboard",
            href: "/",
          },
          {
            icon: <List className="h-5 w-5" />,
            label: "Courses",
            href: "/courses",
          },
          {
            icon: <LineChart className="h-5 w-5" />,
            label: "Analytics",
            href: "/analytics",
          },
        ]
      : user.data?.type === "AD"
      ? [
          {
            icon: <Home className="h-5 w-5" />,
            label: "Dashboard",
            href: "/",
          },
          {
            icon: <List className="h-5 w-5" />,
            label: "Courses",
            href: "/courses",
          },
          {
            icon: <Users2 className="h-5 w-5" />,
            label: "Lecturers",
            href: "/lecturers",
          },
        ]
      : user.data?.type === "LN"
      ? [
          {
            icon: <Home className="h-5 w-5" />,
            label: "Dashboard",
            href: "/",
          },
          {
            icon: <Compass className="h-5 w-5" />,
            label: "Browse",
            href: "/browse",
          },
        ]
      : [];

  return (
    <aside className="fixed inset-y-0 left-0 z-10 flex w-14 flex-col border-r bg-background">
      <TooltipProvider>
        <nav className="flex flex-col items-center gap-4 px-2 py-4">
          <Link
            href="/"
            className="group flex shrink-0 items-center justify-center gap-2 rounded-full bg-primary text-lg font-semibold text-primary-foreground h-8 w-8"
          >
            <BookOpenTextIcon className="h-5 w-5 transition-all group-hover:scale-110" />
            <span className="sr-only">LMS</span>
          </Link>
          {routes.map(({ icon, label, href }, index) => (
            <Tooltip key={index}>
              <TooltipTrigger asChild>
                <Link
                  href={href}
                  className={cn(
                    "flex items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground h-8 w-8",
                    (pathName === href || pathName.startsWith(href + "/")) &&
                      "text-foreground"
                  )}
                >
                  {icon}
                  <span className="sr-only">{label}</span>
                </Link>
              </TooltipTrigger>
              <TooltipContent side="right">{label}</TooltipContent>
            </Tooltip>
          ))}
        </nav>
        <nav className="mt-auto flex flex-col items-center gap-4 px-2 py-4">
          <ThemeButton />
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="outline"
                size="icon"
                className="overflow-hidden rounded-full"
              >
                <User2 />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <Link href="/profile">
                <DropdownMenuItem>Profile</DropdownMenuItem>
              </Link>
              <DropdownMenuItem onClick={signOut}>Sign out</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </nav>
      </TooltipProvider>
    </aside>
  );
}
