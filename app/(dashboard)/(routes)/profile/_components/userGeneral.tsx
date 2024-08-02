import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
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
        name="name"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Name</FormLabel>
            <FormControl>
              <Input type="text" placeholder="Enter your name" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="oldPassword"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Old password</FormLabel>
            <FormControl>
              <Input
                type="password"
                placeholder="Enter old password"
                {...field}
              />
            </FormControl>
            <FormDescription>
              You must reenter your password to save your changes.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="password"
        render={({ field }) => (
          <FormItem>
            <FormLabel>New password</FormLabel>
            <FormControl>
              <Input
                type="password"
                placeholder="Enter new password (Optional)"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
