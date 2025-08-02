import { drizzle } from 'drizzle-orm/node-postgres';
import {Pool} from 'pg';


const pool = new Pool({
        connectionString: "postgresql://postgres:whale123@db:5432/kardb" ,

});

export const db = drizzle(pool);