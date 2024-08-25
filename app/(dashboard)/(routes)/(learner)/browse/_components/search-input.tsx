"use client";
import qs from "query-string";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { GlobeIcon, UserIcon } from "lucide-react";
import { Search } from "lucide-react";
import { usePathname, useSearchParams, useRouter } from "next/navigation";
import { useDebounce } from "@/hooks/use-debounce";
import { useEffect, useState } from "react";

export const SearchInput = () => {
  const [value, setValue] = useState("");
  const debouncedValue = useDebounce(value, 500);

  const searchParams = useSearchParams();
  const router = useRouter();
  const pathName = usePathname();

  const currentCategoryId = searchParams.get("categoryId");

  useEffect(() => {
    const url = qs.stringifyUrl(
      {
        url: pathName,
        query: {
          title: debouncedValue,
          categoryId: currentCategoryId,
        },
      },
      { skipNull: true, skipEmptyString: true }
    );

    router.push(url);
  }, [debouncedValue, currentCategoryId, pathName, router]);

  return (
    <header className="flex items-center justify-between py-4">
      <div className="flex items-center space-x-4">
        <Search className="w-4 h-4" />
        <Input
          onChange={(e) => setValue(e.target.value)}
          value={value}
          type="search"
          placeholder="What do you want to learn?"
          className="w-64"
        />
        <Button variant="ghost" size="icon">
          <GlobeIcon className="w-6 h-6" />
        </Button>
        <Button variant="ghost" size="icon">
          <UserIcon className="w-6 h-6" />
        </Button>
      </div>
    </header>
  );
};
