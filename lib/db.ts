import mssql from "mssql";

const connection = new mssql.ConnectionPool(
  {
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_URL!,
    port: parseInt(process.env.DB_PORT!),
    database: process.env.DB_NAME,
    options: {
      encrypt: false,
      trustServerCertificate: true,
    },
  },
  () => console.log("Connected to Database!")
).connect();

export async function db() {
  return (await connection).request();
}
