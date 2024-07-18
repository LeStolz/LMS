"use client";

import * as React from "react";
import Link from "next/link";
import { Search } from "lucide-react";

import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";

import { Input } from "@/components/ui/input";

import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { toCapitalCase } from "@/lib/utils";
import Navbar from "./_components/navbar";

function getBreadCrumbs(pathName: string) {
  const paths = pathName.split("/");

  if (paths[1] === "") {
    paths.pop();
  }

  for (let i = 1; i < paths.length; i++) {
    paths[i] = paths[i - 1] + "/" + paths[i];
  }
  paths[0] = "/";

  return paths.map((path) => {
    return {
      label: toCapitalCase(path.split("/").at(-1) || "dashboard"),
      href: path,
    };
  });
}

export default function Layout({ children }: React.PropsWithChildren<{}>) {
  const pathName = usePathname();
  const [breadCrumbs, setBreadCrumbs] = useState(() =>
    getBreadCrumbs(pathName)
  );

  useEffect(() => {
    setBreadCrumbs(getBreadCrumbs(pathName));
  }, [pathName]);

  return (
    <div className="flex min-h-screen w-full flex-col">
      <Navbar />
      <div className="flex flex-col gap-4 py-4 pl-14">
        <header className=" top-0 z-30 flex items-center gap-4 static h-auto border-0 bg-transparent px-8">
          <Breadcrumb className="flex">
            <BreadcrumbList>
              {breadCrumbs.map(({ label, href }, index) => (
                <React.Fragment key={index}>
                  <BreadcrumbItem>
                    <BreadcrumbLink asChild>
                      <Link href={href}>{label}</Link>
                    </BreadcrumbLink>
                  </BreadcrumbItem>
                  {index !== breadCrumbs.length - 1 && (
                    <BreadcrumbSeparator key={index} />
                  )}
                </React.Fragment>
              ))}
            </BreadcrumbList>
          </Breadcrumb>
        </header>
        <main className="px-8">{children}</main>
      </div>
    </div>
  );
}
