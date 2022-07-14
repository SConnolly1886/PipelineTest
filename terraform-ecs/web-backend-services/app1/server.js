'use strict';
import fetch from 'node-fetch';
import express from 'express'


// Constants
const PORT = 3000;
const HOST = '0.0.0.0';
const INTERNAL_ALB='forrester.internal'

// App
const app = express();
app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

// app.get('/customers/app1', (req, res) => {
//     res.send('This is app1 - different TG than web and connects to app2 data (even prettier than the homepage)');
// });

app.get('/customers/:customerId', (req, res) => {
    let customerId = req.params['customerId']
    let customerName = 'Patrick Henry'
    getCustomerAccountInfo(req,res,customerId);
});

async function getCustomerAccountInfo (req, res, customerId) {
    let response;
    if (customerId == "app1") {
        res.send('This is app1 - different TG than web and connects to app2 data (even prettier than the homepage)');
    }else {
        try {
            response = await fetch(`http://${INTERNAL_ALB}/transaction/customer/${customerId}`)  ;
            let accounts = await response.text();
            res.status(200).json({
                id: customerId,
                name: 'Patrick Henry',
                accounts: JSON.parse(accounts)
            });
    }
        catch (err) {
            console.log('Http error', err);
            return res.status(500).send();
        }
    }
}

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);