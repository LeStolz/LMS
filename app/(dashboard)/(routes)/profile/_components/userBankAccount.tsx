import {
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useFormContext } from "react-hook-form";

export default function CourseGeneral() {
  const form = useFormContext();

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
  );
}
