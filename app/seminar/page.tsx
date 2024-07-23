"use client";

import { Button } from "@/components/ui/button";
import { useState } from "react";
import { searchCourse, updateCourseSubtitle } from "../api/seminar/seminar";

export default function Page() {
  const [intervalId, setIntervalId] = useState<number>();
  
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
                  const title = ["the", "of", "and", "a", "an", "sql", "how"];
                  const id = Math.floor(Math.random() * 3 + 4);
                  console.log(id);
                  updateCourseSubtitle({
                    subtitle: Math.random().toString(),
                    id: id,
                  });

                  updateCourseSubtitle({
                    subtitle: Math.random().toString(),
                    id: id,
                  });

                  searchCourse({
                    title: title[Math.floor(Math.random() * title.length)]
                  });
                }, 3000)
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
