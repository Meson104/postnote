import { Router, Request, Response } from 'express';
import { db } from '../db';
import { NewUser, users } from '../db/schema';
import { eq } from "drizzle-orm";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dotenv from 'dotenv';
import { auth, AuthRequest } from '../middlewares/auth.middleware';

dotenv.config();


const authRouter = Router(); 
//-----------------SIGNUP body------------------------------------

interface SignUpBody{
    name : string;
    email : string; 
    password : string;
}
authRouter.post("/signup", async (req : Request<{},{},SignUpBody>, res : Response) => {
    try{
        // get req body
        const {name, email, password} = req.body;
        //check if user already exists
        const existingUser = await db.select().from(users).where(eq(users.email,email));
        //this returns a list of users, we need to check if it is empty
        if(existingUser.length){
            res.status(400).json({error:"User already exists"});
            return;
        }
        //hash password
        const hashedPassword = await bcrypt.hash(password , 10,)
        //create user in db
        const newUser : NewUser = {
            name , email , password : hashedPassword,
        }
       const [user] = await db.insert(users).values(newUser).returning();
       res.status(201).json(user);
       
    }

    catch(e){
        res.status(500).json({error:e});
        

    }
});


//-----------------lOGIN body------------------------------------

interface LoginBody {
    email: string;
    password: string;
}
authRouter.post("/login", async(req:Request<{},{},LoginBody>, res:Response) =>{
    try{

        const {email,password} = req.body;

       const [existingUser] = await db.select().from(users).where(eq(users.email,email));
       if(!existingUser){
            res.status(404).json({error: "User with this email does't exist, please register"});
            return;

       }
         //check password
        const isMatch = await bcrypt.compare(password, existingUser.password);
        if(!isMatch){
            res.status(400).json({error:"Incorrect credentials - password"});
            return;
        }

        const token = jwt.sign({id:existingUser.id}, process.env.JWT_SECRET!)

        res.status(200).json({token, ...existingUser});
            
        

    }
    catch(e){
        res.status(500).json({error:e});
    }
});

authRouter.post("/tokenIsValid", async(req , res)=> {
    try{

        const token = req.header("x-auth-token");
        if(!token){
            res.json(false);
            return;
        }
        const verified = jwt.verify(token, process.env.JWT_SECRET!);
        if(!verified){
            res.json(false);
            return;
        }
        const verifiedToken = verified as {id: string};
        const user = await db.select().from(users).where(eq(users.id, verifiedToken.id));

        if(!user){
            res.json(false);
            return;
        }

        res.status(200).json(true);

    }
    catch(e){
        res.status(500).json(false);
    }
})


authRouter.get("/",auth, (req : AuthRequest, res) => {
    try{

        if(!req.user){
            res.status(404).json({error: "User not found"});
            return;
        }

        const user = db.select().from(users).where(eq(users.id,req.user));

        res.status(200).json({...user, token : req.token}); 

       

    }
    catch(e){
        res.status(500).json(false);
    }
}); 

export default authRouter;  