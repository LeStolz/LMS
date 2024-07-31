import {
  FormControl,
  FormDescription,
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
import { Textarea } from "@/components/ui/textarea";
import { useFormContext } from "react-hook-form";
import { CourseCategories } from "./courseCategories";

export default function CourseGeneral() {
  const form = useFormContext();

  return (
    <div className="space-y-6 mt-6">
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
            <FormDescription>
              Course level is required for publishing.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="description"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Description</FormLabel>
            <FormControl>
              <Textarea
                placeholder="Tell us a bit more about your course"
                {...field}
              />
            </FormControl>
            <FormDescription>
              Description should be at least 200 words long for publishing.
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />

      <CourseCategories />

      <FormField
        control={form.control}
        name="price"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Price in $</FormLabel>
            <FormControl>
              <Input
                type="number"
                min={0}
                placeholder="Enter your course price in $"
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
