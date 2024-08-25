'use client';

import React, { Dispatch, SetStateAction } from 'react';

import { Button } from '@/components/ui/button';
import { Form } from '@/components/ui/form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { useForm } from 'react-hook-form';
import * as z from 'zod';
import { deleteCourse } from '@/app/api/course/course';
import { useRouter } from "next/navigation";
import { toast } from "sonner";

const formSchema = z.object({
  cardId: z.number(),
});

export default function RejecteForm({
  cardId,
  setIsOpen,
}: {
  cardId: number;
  setIsOpen: Dispatch<SetStateAction<boolean>>;
}) {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      cardId: cardId,
    },
  });

  const isLoading = form.formState.isSubmitting;
  const router = useRouter();

  const onSubmit = async () => {
    try {
      await deleteCourse({ id: cardId });
      // router.push(`/courses`);
      setIsOpen(false);
      
      toast.success("Course deleted!");

      setTimeout(() => {
        window.location.reload();
      }, 2000);
      
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="space-y-6  sm:px-0 px-4"
      >
        <div className="w-full flex justify-center sm:space-x-6">
          <Button
            size="lg"
            variant="outline"
            disabled={isLoading}
            className="w-full hidden sm:block"
            type="button"
            onClick={() => setIsOpen(false)}
          >
            Cancel
          </Button>
          <Button
            size="lg"
            type="submit"
            disabled={isLoading}
            className="w-full bg-red-500 hover:bg-red-400"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Rejecting...
              </>
            ) : (
              <span>Reject</span>
            )}
          </Button>
        </div>
      </form>
    </Form>
  );
}