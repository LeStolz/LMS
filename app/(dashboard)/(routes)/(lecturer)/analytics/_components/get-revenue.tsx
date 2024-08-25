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
  const [year, setYear] = useState<any>();
  const [month, setMonth] = useState<any>();
  const [revenue, setRevenue] = useState<Number>(0);
  const mutate = useMutation({
    mutationFn: getRevenue,
    onMutate: () => {
      return { year, month };
    },
    onSuccess: (data: any) => {
      setRevenue(data);
      console.log(data);
    },
  });

  return (
    <>
      <form
        onSubmit={() => {
          mutate.mutate(year, month);
        }}
        className="space-y-4"
      >
        <div>
          <label
            htmlFor="year"
            className="block text-sm font-medium text-gray-700"
          >
            year
          </label>
          <Input
            type="number"
            id="year"
            name="year"
            value={year}
            onChange={(e) => setYear(e.target.value)}
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
            onChange={(e) => setMonth(e.target.value)}
            required
          />
        </div>
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
