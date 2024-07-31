import { searchCategories } from "@/app/api/category/category";
import { FormField, FormItem, FormLabel } from "@/components/ui/form";
import {
  MultiSelector,
  MultiSelectorTrigger,
  MultiSelectorInput,
  MultiSelectorContent,
  MultiSelectorList,
  MultiSelectorItem,
} from "@/components/ui/multiselector";
import { useQuery } from "@tanstack/react-query";
import React from "react";
import { useFormContext } from "react-hook-form";

export function CourseCategories() {
  const form = useFormContext();
  const [commandInput, setCommandInput] = React.useState<string>("");
  const results = useQuery({
    queryKey: ["courseCategories"],
    queryFn: async () => await searchCategories({ title: commandInput }),
  });

  return (
    <FormField
      control={form.control}
      name="categoryIds"
      render={({ field }) => (
        <FormItem>
          <FormLabel>Categories</FormLabel>
          <MultiSelector
            inputValue={commandInput}
            setInputValue={setCommandInput}
            onValuesChange={field.onChange}
            values={field.value}
            shouldFilter={false}
          >
            <MultiSelectorTrigger>
              <MultiSelectorInput placeholder="Select your course's categories" />
            </MultiSelectorTrigger>
            <MultiSelectorContent>
              <MultiSelectorList>
                {results.data?.map((category) => (
                  <MultiSelectorItem
                    key={category.id}
                    value={`${category.id}`}
                    name={category.title}
                  >
                    {category.title}
                  </MultiSelectorItem>
                ))}
              </MultiSelectorList>
            </MultiSelectorContent>
          </MultiSelector>
        </FormItem>
      )}
    />
  );
}
