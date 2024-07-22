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
import { useFormContext } from "react-hook-form";

export default function CourseGeneral() {
  const form = useFormContext();

  return (
    <>
      <FormField
        control={form.control}
        name="title"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Title</FormLabel>
            <FormControl>
              <Input type="text" placeholder="Enter course title" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="subtitle"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Subtitle</FormLabel>
            <FormControl>
              <Input
                type="text"
                placeholder="Enter course subtitle"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="level"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Level</FormLabel>
            <Select
              required
              {...field}
              onValueChange={field.onChange}
              defaultValue={field.value}
            >
              <FormControl>
                <SelectTrigger id="type" className="w-full">
                  <SelectValue placeholder="Select course level" />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                <SelectItem value="B">Beginner</SelectItem>
                <SelectItem value="I">Intermediate</SelectItem>
                <SelectItem value="A">Advanced</SelectItem>
              </SelectContent>
            </Select>
            <FormMessage />
          </FormItem>
        )}
      />
    </>
  );
}
