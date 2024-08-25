import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import CourseForm from "./_components/courseForm";
import { Suspense } from "react";
import { Loader2 } from "lucide-react";

export default async function Component() {
  return (
    <div className="container px-0 max-w-6xl">
      <div className="flex flex-col gap-y-2">
        <h1 className="text-2xl font-bold pb-4">Course List</h1>
      </div>
      <Suspense fallback={<Loader2 className="animate-spin" />}>
        <CourseForm />
      </Suspense>
    </div>
  );
}
