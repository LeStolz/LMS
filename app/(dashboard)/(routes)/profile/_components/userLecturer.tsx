import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Textarea } from "@/components/ui/textarea";
import { UploadButton } from "@/lib/uploadthing";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import Image from "next/image";
import { useFieldArray, useFormContext } from "react-hook-form";
import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Delete, Plus } from "lucide-react";
import { AspectRatio } from "@/components/ui/aspect-ratio";

export default function CourseGeneral({
  onSubmit,
}: {
  onSubmit: (values: any) => any;
}) {
  const form = useFormContext();

  const {
    fields: certFields,
    append: appendCert,
    remove: removeCert,
  } = useFieldArray({
    control: form.control,
    name: "certificates",
  });

  const {
    fields: workFields,
    append: appendWork,
    remove: removeWork,
  } = useFieldArray({
    control: form.control,
    name: "workExperiences",
  });

  console.log(workFields);

  return (
    <div className="space-y-6 mt-6">
      <FormField
        control={form.control}
        name="profileImage"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Profile image</FormLabel>
            <FormControl>
              <>
                {form.getValues("profileImage") && (
                  <div className="relative rounded-full max-w-64 max-h-64 w-64 h-64 mx-auto">
                    <Image
                      src={form.getValues("profileImage")}
                      fill
                      alt="profileImage"
                      className="object-cover rounded-full"
                    />
                  </div>
                )}
                <UploadButton
                  className="pt-2"
                  endpoint="courseThumbnail"
                  onClientUploadComplete={async (res) => {
                    if (form.getValues("profileImage") != res[0].url) {
                      await fetch("/api/uploadthing", {
                        method: "DELETE",
                        body: JSON.stringify({
                          url: form.getValues("profileImage"),
                        }),
                      });
                    }

                    form.setValue("profileImage", res[0].url);
                    onSubmit(form.getValues());
                  }}
                  onUploadError={(error: Error) => {
                    toast.error(error.message);
                  }}
                />
              </>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={form.control}
        name="academicRank"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Academic rank</FormLabel>
            <Select
              {...field}
              onValueChange={field.onChange}
              defaultValue={field.value}
            >
              <FormControl>
                <SelectTrigger id="academicRank" className="w-full">
                  <SelectValue placeholder="Select your academic rank" />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                <SelectItem value="A">A</SelectItem>
                <SelectItem value="B">B</SelectItem>
                <SelectItem value="C">C</SelectItem>
                <SelectItem value="D">D</SelectItem>
                <SelectItem value="E">E</SelectItem>
              </SelectContent>
            </Select>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="academicDegree"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Academic degree</FormLabel>
            <Select
              {...field}
              onValueChange={field.onChange}
              defaultValue={field.value}
            >
              <FormControl>
                <SelectTrigger id="academicDegree" className="w-full">
                  <SelectValue placeholder="Select your academic degree" />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                <SelectItem value="B">Bachelor</SelectItem>
                <SelectItem value="M">Master</SelectItem>
                <SelectItem value="D">Doctor</SelectItem>
              </SelectContent>
            </Select>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={form.control}
        name="phone"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Phone</FormLabel>
            <FormControl>
              <Input
                type="tel"
                placeholder="Enter your phone number"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="introduction"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Introduction</FormLabel>
            <FormControl>
              <Textarea
                placeholder="Tell us a bit more about yourself"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="dob"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Birthdate</FormLabel>
            <FormControl>
              <Input
                type="date"
                placeholder="Enter birthdate"
                {...field}
                value={
                  field.value == null
                    ? ""
                    : typeof field.value === "string"
                    ? field.value
                    : (field.value as Date).toISOString().split("T")[0]
                }
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="gender"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Gender</FormLabel>
            <Select
              {...field}
              onValueChange={field.onChange}
              defaultValue={field.value}
            >
              <FormControl>
                <SelectTrigger id="gender" className="w-full">
                  <SelectValue placeholder="Select your gender" />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                <SelectItem value="M">Male</SelectItem>
                <SelectItem value="F">Female</SelectItem>
              </SelectContent>
            </Select>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="homeAddress"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Home address</FormLabel>
            <FormControl>
              <Textarea placeholder="Enter your home address" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="workAddress"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Work address</FormLabel>
            <FormControl>
              <Textarea placeholder="Enter your work address" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="nationality"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Nationality code</FormLabel>
            <FormControl>
              <Input
                type="text"
                placeholder="Enter nationality code"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="annualIncome"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Annual income in $</FormLabel>
            <FormControl>
              <Input
                type="number"
                min={0}
                placeholder="Enter your annual income in $"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormItem>
        <FormLabel>Certificates</FormLabel>
        <div>
          {certFields.map((item, index) => (
            <div key={item.id} className="w-full flex flex-col gap-3 mb-3">
              <div className="w-full flex">
                <FormField
                  control={form.control}
                  name={`certificates.${index}.title`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="text"
                          placeholder="Title"
                          {...field}
                          id={`certificates.${index}.title`}
                          className="rounded-e-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <Button
                  type="button"
                  onClick={async () => {
                    if (form.getValues(`certificates.${index}.image`) != null) {
                      await fetch("/api/uploadthing", {
                        method: "DELETE",
                        body: JSON.stringify({
                          url: form.getValues(`certificates.${index}.image`),
                        }),
                      });

                      onSubmit(form.getValues());
                    }

                    removeCert(index);
                  }}
                  variant="destructive"
                  className="rounded-s-none"
                >
                  <Delete className="w-4 h-4" />
                </Button>
              </div>

              <FormField
                control={form.control}
                name={`certificates.${index}.image`}
                render={({ field }) => (
                  <FormItem>
                    <FormControl>
                      <>
                        {form.getValues(`certificates.${index}.image`) && (
                          <AspectRatio className="rounded-md" ratio={16 / 9}>
                            <Image
                              src={form.getValues(
                                `certificates.${index}.image`
                              )}
                              fill
                              alt="certificate"
                              className="object-cover rounded-md"
                            />
                          </AspectRatio>
                        )}
                        <UploadButton
                          endpoint="profileCertImages"
                          onClientUploadComplete={async (res) => {
                            if (
                              form.getValues(`certificates.${index}.image`) !=
                              res[0].url
                            ) {
                              await fetch("/api/uploadthing", {
                                method: "DELETE",
                                body: JSON.stringify({
                                  url: form.getValues(
                                    `certificates.${index}.image`
                                  ),
                                }),
                              });
                            }

                            form.setValue(
                              `certificates.${index}.image`,
                              res[0].url
                            );
                            onSubmit(form.getValues());
                          }}
                          onUploadError={(error: Error) => {
                            toast.error(error.message);
                          }}
                        />
                      </>
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          ))}
          <Button
            type="button"
            onClick={() => appendCert({ title: "", image: "" })}
            variant="default"
          >
            <Plus className="w-4 h-4" />
          </Button>
        </div>
      </FormItem>

      <FormItem>
        <FormLabel>Work experiences</FormLabel>
        <div>
          {workFields.map((item, index) => (
            <div key={item.id} className="w-full flex flex-col mb-3">
              <div className="w-full flex">
                <FormField
                  control={form.control}
                  name={`workExperiences.${index}.topic`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="text"
                          placeholder="Topic"
                          {...field}
                          id={`workExperiences.${index}.topic`}
                          className="rounded-e-none rounded-b-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <Button
                  type="button"
                  onClick={() => {
                    removeWork(index);
                  }}
                  variant="destructive"
                  className="rounded-s-none rounded-b-none"
                >
                  <Delete className="w-4 h-4" />
                </Button>
              </div>

              <div className="flex">
                <FormField
                  control={form.control}
                  name={`workExperiences.${index}.organizationName`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="text"
                          placeholder="Organization name"
                          {...field}
                          id={`workExperiences.${index}.organizationName`}
                          className="rounded-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name={`workExperiences.${index}.role`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="text"
                          placeholder="Your role"
                          {...field}
                          id={`workExperiences.${index}.role`}
                          className="rounded-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="flex">
                <FormField
                  control={form.control}
                  name={`workExperiences.${index}.fromDate`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="date"
                          placeholder="Work start date"
                          {...field}
                          value={
                            field.value == null
                              ? ""
                              : typeof field.value === "string"
                              ? field.value
                              : (field.value as Date)
                                  .toISOString()
                                  .split("T")[0]
                          }
                          id={`workExperiences.${index}.fromDate`}
                          className="rounded-t-none rounded-e-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name={`workExperiences.${index}.toDate`}
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormControl>
                        <Input
                          type="date"
                          placeholder="Work end date"
                          {...field}
                          value={
                            field.value == null
                              ? ""
                              : typeof field.value === "string"
                              ? field.value
                              : (field.value as Date)
                                  .toISOString()
                                  .split("T")[0]
                          }
                          id={`workExperiences.${index}.toDate`}
                          className="rounded-t-none rounded-s-none"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>
          ))}
          <Button
            type="button"
            onClick={() =>
              appendWork({
                topic: "",
                role: "",
                organization: "",
                fromDate: "",
                toDate: "",
              })
            }
            variant="default"
          >
            <Plus className="w-4 h-4" />
          </Button>
        </div>
      </FormItem>
    </div>
  );
}
