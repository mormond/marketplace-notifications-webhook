const axios = require('axios').default;

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const sig = req.query.sig;

    context.log("sig: " + sig);
    context.log("body: " + JSON.stringify(req.body));

    if ((sig) &&
        (req.body.eventType && req.body.eventType === 'PUT') &&
        (req.body.provisioningState && req.body.provisioningState === 'Succeeded')) {

        const resourceSegments = req.body.applicationId.split('/');
        const subscriptionId = resourceSegments[2];
        const rgName = resourceSegments[4];
        const appName = resourceSegments[8];

        const payload = {
            subscriptionId: subscriptionId,
            rgName: rgName,
            appName: appName,
            ...req.body
        };

        const url = process.env["WORKFLOW_URI"];

        axios({
            method: 'post',
            url: url,
            data: payload
        })

            .then(function (response) {
                console.log(response);
            })
            .catch(function (error) {
                console.log(error);
            });

        context.res = { status: 200 };
    }
    else {
        context.res = { status: 400 };
    }
}