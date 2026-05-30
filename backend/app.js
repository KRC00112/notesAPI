const express=require('express');
const app=express();
const port=5000;
const {Pool}=require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'postgres',
    database: 'notesdb',
    password: '1234',
    port: 5432,
})

app.use(express.json());
app.get('/',async(req,res)=>{

    try{
        const results=await pool.query("SELECT * FROM notes");
        res.json(results.rows);
    } catch (e){
        res.status(500).json({error: e});
    }
})

app.get('/:id',async(req,res)=>{
    try{
        const results=await pool.query("SELECT * FROM notes WHERE note_id=$1",[req.params.id]);
        res.json(results.rows);
    }catch(err){
        res.status(500).json({error: err});
    }
})

app.post('/', async(req,res)=>{
    try{
        const results=await pool.query("INSERT INTO notes(note) VALUES($1) RETURNING *",[req.body.note]+"-i")
        res.json(results.rows[0]);
    }catch(err){
        res.status(500).json({error: err});
    }
})

app.delete('/:id',async(req,res)=>{
    try{
        const results=await pool.query("DELETE FROM notes WHERE note_id=$1 RETURNING *",[req.params.id]);
        res.json(results.rows[0]);
    }catch(err){
        res.status(500).json({error: err});
    }
})

app.put('/:id',async(req,res)=>{
    try{
        const results=await pool.query("UPDATE notes SET note=$1 WHERE note_id=$2 RETURNING *",[req.body.note, req.params.id]);
        res.json(results.rows[0]);
    }catch(err){
        res.status(500).json({error: err});
    }
})

app.listen(port,()=>{
    console.log(`Server started on port ${port}`);
})

process.on('SIGINT', () => {
    pool.end()
    process.exit()
})