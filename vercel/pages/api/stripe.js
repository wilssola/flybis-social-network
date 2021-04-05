const admin = require("../../firebase");

const STRIPE_SECRET_KEY = "sk_test_51HITOvJf8oBYr0MzU7aUdiSBrdzfoIzRa5nUehO2YAW6ptKU1BkIAO0U3shXmvBPVKNmlzZLNI72zDzzVfX3toGb00DLpeOJin";

const stripe = require("stripe")(STRIPE_SECRET_KEY);

const STRIPE_ENDPOINT_KEY = "whsec_xTi5fZpdWUmVRAYZVMhQnVBSraw6qPH8";

export default (req, res) => {
  const STRIPE_SIGNATURE_KEY = req.headers["stripe-signature"];

  const body = req.body;

  let event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      STRIPE_SIGNATURE_KEY,
      STRIPE_ENDPOINT_KEY,
    );
  } catch (error) {
    console.error(error);

    res.statusCode = 400;

    return res.json({ error: error.message });
  }

  const object = event.data.object;
  const type = event.type;
  const request = event.request;

  let result;

  admin.firestore().collection('stripe').doc('test').collection('premium').set({
    'event': type,
    'request': request != null ? true : false,
    'object': object,
  }).then((value) => result = value);
  
  res.statusCode = 200;

  return res.json({ result: result, stripe: "Stripe Key", data: object });
};
