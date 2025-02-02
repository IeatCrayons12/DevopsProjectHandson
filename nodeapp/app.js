const express = require("express");
const app = express();

app.get("/",(req,res)=>{
    res.send("Service is running");
})

app.listen(8080,()=>{
    console.log("Server is up");
})
// hello


// ip to access http://https://54.169.146.197/:8080
