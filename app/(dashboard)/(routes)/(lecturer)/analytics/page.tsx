import { authorize, selectLecturerEarningPerMonth } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import GetRevenue from "./_components/get-revenue";

export default async function Component() {
  const user = await authorize(["LT"]);

  if (!user) {
    return redirect("/");
  }
  
  const getRevenue = async ({year, month} : {year: number, month: number}) => {
    "use server";
    const earnings = await selectLecturerEarningPerMonth({
      id: user.id,
      date: new Date(`${year}-${month}-01`),
      courseId: null,
    });
    return earnings;
  }

  return (
    <div className="p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <GetRevenue user={user} getRevenue={getRevenue}/>
      </div>
    </div>
  );
}
