'use strict';

import express from 'express';

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';
const INTERNAL_ALB='forrester.internal'


// App
const app = express();
app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/transaction/customer/:customerId', (req, res) => {
    let customerId = req.params['customerId']
    return res.status(200).json({
        customerId: 100,
        clients: [
            {
                id: 'C001',
                acNo: 'For01',
                type: 'Existing',
                name: 'Caylent',
                length: '100 days'
            }, {
                id: 'C002',
                acNo: 'For02',
                type: 'Potential',
                name: 'Awesome Company Inc.',
                length: 'N/A'
            }
        ]
    });
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);