"use client";

import { FormProvider, useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { Form, FormMessage } from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { LoaderCircleIcon } from "lucide-react";
import Link from "next/link";
import { formatError } from "@/lib/utils";
import { toast } from "sonner";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useRouter } from "next/navigation";
import { demandLecturerVerification, updateUser } from "@/app/api/user/user";
import UserGeneral from "./userGeneral";
import UserBankAccount from "./userBankAccount";
import UserLecturer from "./userLecturer";
import { UserWithDetails } from "@/types/user";

const formSchema = z.object({
  name: z.string().min(1, {
    message: "Name is required.",
  }),
  oldPassword: z.string().min(5, {
    message: "Old password must be at least 5 characters long.",
  }),
  password: z
    .string()
    .min(5, {
      message: "Password must be at least 5 characters long.",
    })
    .optional(),

  accountNumber: z
    .string()
    .min(16, {
      message: "Account number must 16 characters long.",
    })
    .max(16, {
      message: "Account number must 16 characters long.",
    })
    .optional(),
  goodThru: z.coerce
    .date()
    .min(new Date(), {
      message: "Invalid expiry date.",
    })
    .optional(),
  cvc: z
    .string()
    .min(3, {
      message: "CVC must be 3 digits long.",
    })
    .max(3, {
      message: "CVC must be 3 digits long.",
    })
    .optional(),
  cardholderName: z
    .string()
    .min(1, {
      message: "Cardholder name is required.",
    })
    .optional(),
  zip: z
    .string()
    .min(1, {
      message: "Zip code is required.",
    })
    .optional(),

  dob: z.coerce
    .date()
    .max(new Date(), {
      message: "Invalid date of birth.",
    })
    .optional(),
  gender: z.enum(["M", "F"]).optional(),
  homeAddress: z
    .string()
    .min(1, {
      message: "Home address is required.",
    })
    .optional(),
  workAddress: z
    .string()
    .min(1, {
      message: "Work address is required.",
    })
    .optional(),
  nationality: z
    .string()
    .length(2, {
      message: "Nationality must be 2 characters long.",
    })
    .optional(),
  phone: z
    .string()
    .length(10, {
      message: "Phone number must be 10 digit long.",
    })
    .optional(),
  introduction: z
    .string()
    .min(1, {
      message: "Introduction is required.",
    })
    .optional(),
  annualIncome: z.coerce
    .number()
    .min(0, {
      message: "Annual income must be non-negative.",
    })
    .optional(),
  academicRank: z.enum(["A", "B", "C", "D", "E"]).optional(),
  academicDegree: z.enum(["B", "M", "D"]).optional(),
  profileImage: z
    .string()
    .url()
    .min(1, {
      message: "Profile image is required.",
    })
    .optional(),

  certificates: z
    .array(
      z.object({
        title: z.string().min(1, {
          message: "Title is required.",
        }),
        image: z.string().min(1, {
          message: "Image is required.",
        }),
      })
    )
    .optional(),
  workExperiences: z
    .array(
      z.object({
        topic: z.string().min(1, {
          message: "Topic is required.",
        }),
        role: z.string().min(1, {
          message: "Role is required.",
        }),
        organizationName: z.string().min(1, {
          message: "Organization name is required.",
        }),
        fromDate: z.coerce.date().max(new Date(), {
          message: "Invalid from date.",
        }),
        toDate: z.coerce.date(),
      })
    )
    .optional(),
});

export default function Component({ user }: { user: UserWithDetails }) {
  const router = useRouter();
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      ...user,
      accountNumber: user.accountNumber ?? undefined,
      goodThru: user.goodThru ?? undefined,
      cvc: user.cvc ?? undefined,
      cardholderName: user.cardholderName ?? undefined,
      zip: user.zip ?? undefined,

      dob: user.dob ?? undefined,
      gender: user.gender ?? undefined,
      homeAddress: user.homeAddress ?? undefined,
      workAddress: user.workAddress ?? undefined,
      nationality: user.nationality ?? undefined,
      phone: user.phone ?? undefined,
      introduction: user.introduction ?? undefined,
      annualIncome: user.annualIncome ?? undefined,
      academicRank: user.academicRank ?? undefined,
      academicDegree: user.academicDegree ?? undefined,
      profileImage: user.profileImage ?? undefined,
    },
  });

  const { isSubmitting, isValid, errors } = form.formState;
  const [error, setError] = useState<string | undefined>(undefined);

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      await updateUser({
        id: user.id,
        type: user.type,
        ...values,
        password:
          values.password == null || values.password === ""
            ? values.oldPassword
            : values.password,
      });

      toast.success("Profile saved!");

      router.refresh();
      setError(undefined);
    } catch (error) {
      if (formatError(error).includes("Bank")) {
        toast.success("General info saved!");
      } else if (formatError(error).includes("Lecturer")) {
        toast.success("General info and bank account saved!");
      }
      setError(formatError(error));
    }
  }

  async function onVerify() {
    try {
      await demandLecturerVerification({
        id: user.id,
      });

      toast.success("Verification demanded!");

      setError(undefined);
    } catch (error) {
      setError(formatError(error));
    }
  }

  return (
    <FormProvider {...form}>
      <Form {...form}>
        <form className="space-y-6" onSubmit={form.handleSubmit(onSubmit)}>
          <Tabs defaultValue="general" className="w-full">
            <TabsList>
              <TabsTrigger value="general">General</TabsTrigger>
              {user.type != "AD" && (
                <TabsTrigger value="bankAccount">Bank account</TabsTrigger>
              )}
              {user.type == "LT" && (
                <TabsTrigger value="lecturer">Lecturer</TabsTrigger>
              )}
            </TabsList>
            <TabsContent value="general">
              <UserGeneral />
            </TabsContent>
            <TabsContent value="bankAccount">
              <UserBankAccount />
            </TabsContent>
            <TabsContent value="lecturer">
              <UserLecturer onSubmit={onSubmit} />
            </TabsContent>
          </Tabs>
          <div>
            <div className="flex flex-row gap-2">
              <Link href="/">
                <Button type="button" variant="ghost">
                  Cancel
                </Button>
              </Link>
              <Button
                type="submit"
                aria-disabled={isSubmitting}
                onClick={(event: any) => {
                  if (isSubmitting) {
                    event.preventDefault();
                  }
                }}
              >
                {isSubmitting ? (
                  <LoaderCircleIcon className="animate-spin" />
                ) : (
                  "Save"
                )}
              </Button>
              {user.type == "LT" && (
                <Button type="button" onClick={onVerify} variant={"secondary"}>
                  Verify
                </Button>
              )}
            </div>
            {error && <FormMessage className="pt-2">{error}</FormMessage>}
          </div>
        </form>
      </Form>
    </FormProvider>
  );
}
