import { Router, Request, Response } from 'express';
import { db } from '../db';
import { NewUser, users } from '../db/schema';
import { eq } from "drizzle-orm";
import bcrypt from "bcryptjs";



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
            res.status(400).json({msg:"Incorrect credentials - password"});
            return;
        }

        res.status(200).json({
            message : "Welcome " + existingUser.name ,
        });

    }
    catch(e){
        res.status(500).json({error:e});
    }
})


authRouter.get("/", (req, res) => {
    res.send('Hi, this is the auth route!');
}); 

export default authRouter;  