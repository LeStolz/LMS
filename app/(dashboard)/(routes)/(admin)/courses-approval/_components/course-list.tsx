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
import { FormProvider, useForm } from "react-hook-form";
import { Form, FormMessage } from "@/components/ui/form";
import PendingCourse from "./pending-course";
import VerifyCourse from "./verify-course";
import RejecteCourse from "./reject-course";
import { searchAllCourse, searchCourseByOwner } from "@/app/api/course/course";
import { redirect } from "next/navigation";

export default async function Component() {
  let pending: any[]= [];
  let verify: any[] = [];
  let reject: any[] = [];
  
  try{
    const allData = await searchAllCourse();
    console.log(allData);
    pending = allData.filter(course => course.status === "P");
    verify = allData.filter(course => course.status === "V");
    reject = allData.filter(course => course.status === "R");
  }
  catch{
    console.log("error");
    return redirect("/");
  }
  return (
    <Tabs defaultValue="pending">
      <TabsList className="grid w-full grid-cols-3">
        <TabsTrigger value="pending">Pending</TabsTrigger>
        <TabsTrigger value="verify">Verify</TabsTrigger>
        <TabsTrigger value="reject">Reject</TabsTrigger>
      </TabsList>
      <TabsContent value="pending">
        <Card>
          <CardHeader>
            <CardTitle>Pending</CardTitle>
            <CardDescription>
              Make changes to your account here. Click save
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <PendingCourse course={pending} />
          </CardContent>
        </Card>
      </TabsContent>
      <TabsContent value="verify">
        <Card>
          <CardHeader>
            <CardTitle>Verify</CardTitle>
            <CardDescription>
              Change your password here. After saving
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <VerifyCourse course={verify}/>
          </CardContent>
        </Card>
      </TabsContent>
      <TabsContent value="reject">
        <Card>
          <CardHeader>
            <CardTitle>Reject</CardTitle>
            <CardDescription>
              Change your password here. After saving
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <RejecteCourse course={reject}/>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  );
}
