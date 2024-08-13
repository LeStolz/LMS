import { getSessionId } from "@/app/api/auth/auth";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import React from "react";
import { useFormContext } from "react-hook-form";
import { searchRegion } from "@/app/api/region/region";
import { toast } from "sonner";
export default function CourseGeneral() {
  const form = useFormContext();

  const [commandInput, setCommandInput] = React.useState<string>("");
  const results = useQuery({
    queryKey: ["courseCategories"],
    queryFn: async () => await searchRegion({ name: commandInput }),
  });

  return (
    <div className="space-y-6 mt-6">
      <FormField
        control={form.control}
        name="accountNumber"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Account number</FormLabel>
            <FormControl>
              <Input
                type="number"
                placeholder="Enter bank account number"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="goodThru"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Good thru</FormLabel>
            <FormControl>
              <Input
                type="date"
                placeholder="Enter expiration date"
                {...field}
                value={
                  field.value == null
                    ? ""
                    : typeof field.value === "string"
                    ? field.value
                    : (field.value as Date).toISOString().split("T")[0]
                }
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="cvc"
        render={({ field }) => (
          <FormItem>
            <FormLabel>CVC</FormLabel>
            <FormControl>
              <Input type="number" placeholder="Enter CVC" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="cardholderName"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Cardholder name</FormLabel>
            <FormControl>
              <Input
                type="text"
                placeholder="Enter cardholder name"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <div className="flex flex-wrap -mx-3 mb-6">
        <div className="w-full md:w-1/2 px-3 mb-6 md:mb-0">
          <FormField
            control={form.control}
            name="regionId"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Region Id</FormLabel>
                <Select
                  {...field}
                  // inputValue={commandInput}
                  // setInputValue={setCommandInput}
                  onValueChange={field.onChange}
                  defaultValue={field.value}
                >
                  <FormControl>
                    <SelectTrigger id="regionId" className="w-full">
                      <SelectValue placeholder="Select your region id" />
                    </SelectTrigger>
                  </FormControl>
                  <SelectContent>
                    {results.data?.map((region) => (
                      <SelectItem key={region.id} value={`${region.id}`}>
                        {region.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>
        <div className="w-full md:w-1/2 px-3">
          <FormField
            control={form.control}
            name="zip"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Zip</FormLabel>
                <FormControl>
                  <Input type="number" placeholder="Enter zip" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>
      </div>
    </div>
  );
}
