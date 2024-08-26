import { SearchBar } from "../browse/_components/search-bar";
import SearchData from "./_components/search-data";

export default async function Component() {

  return (
    <>
      <div className="p-6">
        <SearchBar />
      </div>
      <main className="space-y-8">
        <SearchData />
      </main>
    </>
  );
}
