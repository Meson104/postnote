import {Router} from 'express';
import { auth, AuthRequest } from '../middlewares/auth.middleware';
import { NewNotes, notes } from '../db/schema';
import { db } from '../db';
import { eq } from 'drizzle-orm';

const taskRouter = Router();

taskRouter.post('/',auth, async(req : AuthRequest, res)=>{
    try{
        req.body = {...req.body, uid : req.user};
        const newNote : NewNotes = req.body;

        const [note] = await db.insert(notes).values(newNote).returning();

        res.status(201).json(note);

       
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

taskRouter.get('/',auth, async(req : AuthRequest, res)=>{
    try{
         const allNotes = await db.select().from(notes).where(eq(notes.uid , req.user!));

        res.json(allNotes);
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

taskRouter.delete('/',auth, async(req : AuthRequest, res)=>{
    try{
        const {noteId} : {noteId : string}  = req.body;
         await db.delete(notes).where(eq(notes.id ,noteId ));
        
         res.json(true);
        
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

export default taskRouter;
