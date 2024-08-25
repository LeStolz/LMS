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
import PendingList from "./pending-lec";
import VerifyList from "./verify-lec";
import RejectList from "./reject-lec";

export default async function Component() {
  return (
    <>
      <>
        <form className="space-y-6">
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
                  <PendingList/>
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
                  <VerifyList/>
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
                  <RejectList/>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </form>
      </>
    </>
  );
}
