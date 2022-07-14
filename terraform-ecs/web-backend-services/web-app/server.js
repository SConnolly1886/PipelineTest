'use strict';
import fetch from 'node-fetch';
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';


// Constants
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = 80;
const HOST = '0.0.0.0';
const INTERNAL_ALB='forrester.internal'
const router = express.Router();

router.use(function (req,res,next) {
    console.log('/' + req.method);
    next();
});
 
router.get('/', function(req,res){
    res.sendFile((path.join(__dirname, '/views/home.html')));
});

 
router.use(function (req,res,next) {
    console.log('/' + req.method);
    next();
    });
     
router.get('/', function(req,res){
    res.sendFile(path + '/views/home.html');
});

// App
const app = express();
app.use('/', router);

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/customers/:customerId', (req, res) => {
    let customerId = req.params['customerId']
    fetchCustomer(req,res,customerId);
});

app.get('/customers/app1', (req, res) => {
    fetchApp1(req,res);
});

async function fetchCustomer (req, res,customerId) {
    let response;
    try {
        response = await fetch(`http://${INTERNAL_ALB}/customers/${customerId}`)  ;
        let data = await response.text();
        console.log(data)
        return res.send(data);
    } catch (err) {
        console.log('Http error', err);
        return res.status(500).send();
    }
}

async function fetchApp1 (req, res) {
    let response;
    try {
        response = await fetch(`http://${INTERNAL_ALB}/customers/app1`)  ;
        let data = await response.text();
        console.log(data)
        return res.send(data);
    } catch (err) {
        console.log('Http error', err);
        return res.status(500).send();
    }
}

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

 
 

 