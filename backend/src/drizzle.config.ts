import { defineConfig } from 'drizzle-kit';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

// Type-safe access to environment variables
const LOCAL_DB_HOST = process.env.LOCAL_DB_HOST!;
const LOCAL_DB_PORT = Number(process.env.LOCAL_DB_PORT!);
const DB_NAME = process.env.DB_NAME!;
const DB_USER = process.env.DB_USER!;
const DB_PASSWORD = process.env.DB_PASSWORD!;

export default defineConfig({
  dialect: 'postgresql',
  schema: './db/schema.ts',
  out: './drizzle',
  dbCredentials: {
    host: LOCAL_DB_HOST,
    port: LOCAL_DB_PORT,
    database: DB_NAME,
    user: DB_USER,
    password: DB_PASSWORD,
    ssl: false,
  },
});
