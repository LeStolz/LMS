"use client";

import { Button } from "@/components/ui/button";
import { useState } from "react";
import { searchCourse, updateCourseSubtitle } from "../api/seminar/seminar";
import { useRouter } from "next/navigation";

export default function Page() {
  const [intervalId, setIntervalId] = useState<number>();
  const [count, setCount] = useState(0);

  return (
    <div className="container flex justify-center items-center h-screen">
      <div className="flex flex-col">
        <h1 className="text-2xl font-bold pb-2">Seminar</h1>

        <div className="space-x-4">
          <Button
            variant="destructive"
            onClick={() =>
              setIntervalId(
                window.setInterval(() => {
                  setCount((count) => (count + 1) % 100);

                  updateCourseSubtitle({
                    subtitle: Math.random().toString(),
                    id: count,
                  });

                  searchCourse({
                    title: Math.random().toString(),
                  });
                }, 100)
              )
            }
          >
            Send requests
          </Button>

          <Button
            onClick={() => {
              clearInterval(intervalId);
            }}
          >
            Stop requests
          </Button>
        </div>
      </div>
    </div>
  );
}
