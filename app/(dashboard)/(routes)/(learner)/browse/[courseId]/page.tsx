import { getCourse } from "@/app/api/course/[courseId]/route";
import { redirect } from "next/navigation";
import { columns } from "./_components/column";
import { DataTable } from "./_components/data-table";

interface CourseDetailsProps {
  course: {
    advertisementVideo: string;
    categories: { id: number; name: string }[];
    createdAt: Date;
    description: string;
    id: number;
    learnerCount: number;
    lecturerCount: number;
    level: string;
    minutesToComplete: number;
    price: number;
    raterCount: number;
    rating: number;
    sections: any[];
    status: string;
    subtitle: string;
    thumbnail: string;
    title: string;
    updatedAt: Date;
    visitorCount: number;
  };
}

const CourseDetail = async ({ params }: { params: { courseId: string } }) => {
  let course;
  try {
    course = await getCourse({
      id: parseInt(params.courseId),
      withCategories: true,
      withSections: true,
      withReviews: true,
    });
  } catch {
    return redirect("/");
  }

  console.log("course", course);
  return (
    <div className="p-4">
      <div className="flex flex-col items-center">
        <img
          src={course.thumbnail}
          alt={course.title}
          className="w-full max-w-md rounded-lg shadow-md"
        />
        <h1 className="text-2xl font-bold mt-4">{course.title}</h1>
        <h2 className="text-xl text-gray-600">{course.subtitle}</h2>
      </div>
      <div className="mt-4">
        <h3 className="text-lg font-semibold">Description</h3>
        <p className="text-gray-700">{course.description}</p>
      </div>
      <div className="mt-4">
        <h3 className="text-lg font-semibold">Advertisement Video</h3>
        <video controls className="w-full max-w-md">
          <source src={course.advertisementVideo} type="video/mp4" />
          Your browser does not support the video tag.
        </video>
      </div>
      <div className="mt-4">
        <h3 className="text-lg font-semibold">Categories</h3>
        <ul className="list-disc list-inside">
          {course.categories.map((category: any) => (
            <li key={category.id}>{category.title}</li>
          ))}
        </ul>
      </div>
      <div className="mt-4">
        <h3 className="text-lg font-semibold">Details</h3>
        <p>
          <strong>Created At:</strong> {course.createdAt.toString()}
        </p>
        <p>
          <strong>Updated At:</strong> {course.updatedAt.toString()}
        </p>
        <p>
          <strong>Level:</strong> {course.level}
        </p>
        <p>
          <strong>Price:</strong> ${course.price}
        </p>
        <p>
          <strong>Learner Count:</strong> {course.learnerCount}
        </p>
        <p>
          <strong>Lecturer Count:</strong> {course.lecturerCount}
        </p>
        <p>
          <strong>Minutes to Complete:</strong> {course.minutesToComplete}
        </p>
        <p>
          <strong>Rating:</strong> {course.rating} ({course.raterCount} ratings)
        </p>
        <p>
          <strong>Visitor Count:</strong> {course.visitorCount}
        </p>
        <p>
          <strong>Status:</strong> {course.status}
        </p>
      </div>
      <p>
        <strong>Review:</strong>
      </p>
      {course.reviews && <DataTable columns={columns} data={course.reviews} />}
    </div>
  );
};

export default CourseDetail;
