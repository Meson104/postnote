import {Router} from 'express';
import { auth, AuthRequest } from '../middlewares/auth.middleware';
import { NewNotes, notes } from '../db/schema';
import { db } from '../db';
import { eq } from 'drizzle-orm';

const notesRouter = Router();

notesRouter.post('/',auth, async(req : AuthRequest, res)=>{
    try{
        req.body = {...req.body,dueAt: new Date(req.body.dueAt), uid : req.user};
        const newNote : NewNotes = req.body;

        const [note] = await db.insert(notes).values(newNote).returning();

        res.status(201).json(note);

       
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

notesRouter.get('/',auth, async(req : AuthRequest, res)=>{
    try{
         const allNotes = await db.select().from(notes).where(eq(notes.uid , req.user!));

        res.json(allNotes);
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

notesRouter.delete('/',auth, async(req : AuthRequest, res)=>{
    try{
        const {noteId} : {noteId : string}  = req.body;
         await db.delete(notes).where(eq(notes.id ,noteId ));
        
         res.json(true);
        
    }
    catch(e){
        res.status(500).json({error:e});
    }
});

notesRouter.post("/sync", auth, async (req: AuthRequest, res) => {
  try {
    // req.body = { ...req.body, dueAt: new Date(req.body.dueAt), uid: req.user };
    const notesList = req.body;

    const filteredNotes: NewNotes[] = [];

    for (let n of notesList) {
      n = {
        ...n,
        dueAt: new Date(n.dueAt),
        createdAt: new Date(n.createdAt),
        updatedAt: new Date(n.updatedAt),
        uid: req.user,
      };
      filteredNotes.push(n);
    }

    const pushedNotes = await db
      .insert(notes)
      .values(filteredNotes)
      .returning();

    res.status(201).json(pushedNotes);
  } catch (e) {
    console.log(e);
    res.status(500).json({ error: e });
  }
}



);

export default notesRouter;
