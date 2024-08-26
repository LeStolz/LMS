"use client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { GlobeIcon, Search, UserIcon } from "lucide-react";
import { usePathname } from "next/navigation";
import { SearchInput } from "./search-input";

export const SearchBar = () => {
  const pathName = usePathname();
  const isSearchPage = pathName === "/browse" || pathName === "/course-all";
  return (
    <>
      {isSearchPage && (
        <div className="hidden md:block">
          <SearchInput />
        </div>
      )}
    </>
  );
};
