import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";
import Link from "next/link";

export default function Component() {
  return (
    <div className="w-full max-w-7xl mx-auto p-4">
      <header className="flex items-center justify-between py-4">
        <div className="flex items-center space-x-4">
          <Input type="search" placeholder="What do you want to learn?" className="w-64" />
          <Button variant="ghost" size="icon">
            <GlobeIcon className="w-6 h-6" />
          </Button>
          <Button variant="ghost" size="icon">
            <UserIcon className="w-6 h-6" />
          </Button>
        </div>
      </header>
      <main className="space-y-8">
        <section>
          <h2 className="text-xl font-semibold">Most Popular Certificates</h2>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Google Data Analytics"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Google Data Analytics</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Google Project Management"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Google Project Management</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Google IT Support"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Google IT Support</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Science"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <Badge variant="secondary">Recently Updated</Badge>
                <h3 className="text-sm font-medium">IBM Data Science</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
          </div>
          <Button variant="outline" className="mt-4">
            Show 6 more
          </Button>
        </section>
        <section>
          <h2 className="text-xl font-semibold">Personalized Specializations for You</h2>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Science"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <Badge variant="secondary">Recently Updated</Badge>
                <h3 className="text-sm font-medium">IBM Data Science</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Google Data Analytics"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Google Data Analytics</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Analyst"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <Badge variant="secondary">Recently Updated</Badge>
                <h3 className="text-sm font-medium">IBM Data Analyst</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Machine Learning Specialization"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Machine Learning Specialization</h3>
                <p className="text-xs text-muted-foreground">Specialization</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
          </div>
          <Button variant="outline" className="mt-4">
            Show 6 more
          </Button>
        </section>
        <section>
          <h2 className="text-xl font-semibold">Explore with a Coursera Plus Subscription</h2>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Science"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">IBM Data Science</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Science"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <Badge variant="secondary">Recently Updated</Badge>
                <h3 className="text-sm font-medium">IBM Data Science</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="Python for Everybody"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">Python for Everybody</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
            <Card>
              <img
                src="https://picsum.photos/400/200"
                alt="IBM Data Science"
                className="w-full h-40 object-cover"
                width="300"
                height="150"
                style={{ aspectRatio: "300/150", objectFit: "cover" }}
              />
              <CardContent>
                <h3 className="text-sm font-medium">IBM Data Science</h3>
                <p className="text-xs text-muted-foreground">Professional Certificate</p>
                <Link href="#" className="text-sm text-blue-600" prefetch={false}>
                  Make progress toward a degree
                </Link>
              </CardContent>
            </Card>
          </div>
        </section>
      </main>
    </div>
  )
}

function GlobeIcon(props:any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="10" />
      <path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20" />
      <path d="M2 12h20" />
    </svg>
  )
}


function UserIcon(props:any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  )
}