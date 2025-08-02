import express from 'express';
import authRouter from './routes/auth';
import dotenv from 'dotenv';
dotenv.config();

const app = express();

app.use(express.json());
app.use("/auth",authRouter);

app.get('/', (req, res) => {
    res.send('Hello , World!!!!!');
})



app.listen(process.env.PORT , ()=>{
    console.log(`Server is up and running on  http://localhost:${process.env.PORT}`);
})