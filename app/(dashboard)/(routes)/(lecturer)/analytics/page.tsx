import { authorize, selectLecturerEarningPerMonth } from "@/app/api/user/user";
import { redirect } from "next/navigation";
import GetRevenue from "./_components/get-revenue";

export default async function Component() {
  const user = await authorize(["LT"]);

  if (!user) {
    return redirect("/");
  }
  
  const getRevenue = async ({userId, year, month} : {userId:number, year: number, month: number}) => {
    "use server";
    const earnings = await selectLecturerEarningPerMonth({
      id: userId,
      year: year,
      month: month
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
