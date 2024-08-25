import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";

import { Button } from "@/components/ui/button";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { UserWithDetails } from "@/types/user";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { useQuery } from "@tanstack/react-query";
import { searchRegion } from "@/app/api/region/region";
import React, { Dispatch, SetStateAction } from "react";
import { enrollInCourse } from "@/app/api/course/[courseId]/route";
import { formatPrice } from "@/lib/format";
import { toast } from "sonner";

const formSchema = z.object({
  accountNumber: z
    .string()
    .min(16, { message: "Account number must be 16 characters long." })
    .max(16, { message: "Account number must be 16 characters long." })
    .optional(),
  goodThru: z.coerce
    .date()
    .min(new Date(), { message: "Invalid expiry date." })
    .optional(),
  cvc: z
    .string()
    .min(3, { message: "CVC must be 3 digits long." })
    .max(3, { message: "CVC must be 3 digits long." })
    .optional(),
  cardholderName: z
    .string()
    .min(1, { message: "Cardholder name is required." })
    .optional(),
  regionId: z.union([z.string(), z.number()]).optional(),
  zip: z.string().min(1, { message: "Zip code is required." }).optional(),
});

export default function Component({
  user,
  courseId,
  coursePrice,
  setIsOpen,
}: {
  user: UserWithDetails;
  courseId: number;
  coursePrice: number | undefined;
  setIsOpen: Dispatch<SetStateAction<boolean>>;
}) {
  const router = useRouter();
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      accountNumber: user.accountNumber ?? undefined,
      goodThru: user.goodThru ?? undefined,
      cvc: user.cvc ?? undefined,
      cardholderName: user.cardholderName ?? undefined,
      regionId: user.regionId ?? undefined,
      zip: user.zip ?? undefined,
    },
  });
  const [commandInput, setCommandInput] = React.useState<string>("");
  const results = useQuery({
    queryKey: ["courseCategories"],
    queryFn: async () => await searchRegion({ name: commandInput }),
  });

  const onSubmit = async () => {
    try {
      await enrollInCourse({
        courseId,
        couponId: null,
      });
      setIsOpen(false);
      toast.success("Course enrolled!");
      router.refresh();
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <div>
      <div className="text-2xl font-bold">
        {coursePrice !== undefined ? formatPrice(coursePrice) : "N/A"}
      </div>
      <div className="w-full flex justify-center sm:space-x-6">
        <Button
          size="lg"
          variant="outline"
          className="w-full hidden sm:block"
          type="button"
          onClick={() => setIsOpen(false)}
        >
          Cancel
        </Button>
        <Button
          size="lg"
          type="submit"
          onClick={onSubmit}
          className="w-full bg-green-500 hover:bg-green-400"
        >
          <span>Purchase</span>
        </Button>
      </div>
    </div>
  );
}
