"use client";
import { authorize } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import { useState } from "react";
import { selectLecturerEarningPerMonth } from "@/app/api/user/user";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Input } from "@/components/ui/input";

export default function Component({
  user,
  getRevenue,
}: {
  user: any;
  getRevenue: any;
}) {
  const [year, setYear] = useState<number | undefined>();
  const [month, setMonth] = useState<number | undefined>();
  const [revenue, setRevenue] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);

  const mutate = useMutation({
    mutationFn: (variables: { year: number; month: number }) => getRevenue(variables),
    onMutate: () => {
      return { year, month };
    },
    onSuccess: (data: any) => {
      setRevenue(data);
      console.log(data);
    },
  });

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    if (year && year > 1 && month && month >= 1 && month <= 12) {
      setError(null);
      mutate.mutate({ year, month });
    } else {
      setError("Please enter a valid year and month.");
    }
  };

  return (
    <>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label
            htmlFor="year"
            className="block text-sm font-medium text-gray-700"
          >
            Year
          </label>
          <Input
            type="number"
            id="year"
            name="year"
            value={year}
            onChange={(e) => setYear(parseInt(e.target.value))}
            required
          />
        </div>
        <div>
          <label
            htmlFor="month"
            className="block text-sm font-medium text-gray-700"
          >
            Month
          </label>
          <Input
            type="number"
            id="month"
            name="month"
            value={month}
            onChange={(e) => setMonth(parseInt(e.target.value))}
            required
          />
        </div>
        {error && <p className="text-red-500">{error}</p>}
        <button
          type="submit"
          className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Get Revenue
        </button>
      </form>
      {revenue !== null && (
        <div className="mt-4">
          <h2 className="text-lg font-semibold">Revenue for {month}</h2>
          <p className="text-xl">${revenue.toString()}</p>
        </div>
      )}
    </>
  );
}