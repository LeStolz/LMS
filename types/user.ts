export type User = {
  id: number;
  email: string;
  name: string;
  type: "AD" | "LN" | "LT";
};

export type UserWithPassword = User & {
  password: string;
};

export type BankAccount = {
  accountNumber: string;
  goodThru: string;
  cvc: string;
  cardholderName: string;
  zip: string;
  ownerId: number;
};

export type UserWithBankAccount = User & BankAccount;

export type Certificate = {
  title: string;
  image: string;
};

export type WorkExperience = {
  topic: string;
  role: string;
  organizationName: string;
  fromDate: Date;
  toDate: Date;
};

export type Lecturer = UserWithBankAccount & {
  dob: Date;
  gender: "M" | "F";
  homeAddress: string;
  workAddress: string;
  nationality: string;
  phone: string;
  introduction: string;
  annualIncome: number;
  academicRank: "A" | "B" | "C" | "D" | "E";
  academicDegree: "B" | "M" | "D";
  profileImage: string;
  certificates: Certificate[];
  workExperiences: WorkExperience[];
};

export type UserWithDetails = UserWithPassword & {
  accountNumber?: string;
  goodThru?: Date;
  cvc?: string;
  cardholderName?: string;
  zip?: string;
  ownerId?: number;
  regionId?: number | string;

  dob?: Date;
  gender?: "M" | "F";
  homeAddress?: string;
  workAddress?: string;
  nationality?: string;
  phone?: string;
  introduction?: string;
  annualIncome?: number;
  academicRank?: "A" | "B" | "C" | "D" | "E";
  academicDegree?: "B" | "M" | "D";
  profileImage?: string;
  certificates?: Certificate[];
  workExperiences?: WorkExperience[];
};
