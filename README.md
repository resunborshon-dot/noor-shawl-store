# NOOR Shawl Store — Netlify starter with bKash gateway scaffold

This project contains:
- NOOR storefront styling (burgundy / ivory / champagne gold)
- Product catalogue and cart
- Checkout with COD, Nagad manual transfer, and bKash gateway initiation
- Delivery fees calculated on the server: Inside Khulna ৳70; outside Khulna ৳140
- Netlify Functions backend and Supabase order storage
- Admin dashboard with payment status, order status and delivery breakdown
- Optional email notifications via Resend and WhatsApp Cloud API template alerts

## Important: bKash activation is not complete until merchant credentials are issued
The bKash integration code is a gateway-ready implementation scaffold. It cannot initiate real or sandbox payments until NOOR receives approved bKash Payment Gateway credentials and the exact environment/API version and callback requirements from bKash. The integration uses server-side token grant, create payment, execute payment and status reconciliation. Verify the request/response field names and callback format against the merchant-specific onboarding pack before production. Test in bKash sandbox first. Never mark an order paid based on the browser redirect alone; the callback function executes/queries payment and checks amount, currency and merchant invoice against the saved order.

Do not ask customers for or store their bKash PIN or OTP. Those are entered only on bKash's secure interface. Keep all credentials in Netlify environment variables, never in browser code or Git.

## 1. Create Supabase database
1. Create a project at https://supabase.com/
2. Open SQL Editor and run `database.sql`. For an existing starter database, the script adds the new delivery and payment columns.
3. Copy the project URL and the `service_role` secret key from Project Settings > API. Keep the key private.

## 2. Configure Netlify environment variables
Add these under Site configuration > Environment variables (Functions runtime access):

Required for the store/admin:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ADMIN_PASSWORD`
- `ADMIN_SESSION_SECRET` (random secret, at least 32 characters)

Required for bKash sandbox/production after merchant onboarding:
- `BKASH_API_BASE_URL` — exact base URL supplied for your sandbox or production account; do not guess it
- `BKASH_USERNAME`
- `BKASH_PASSWORD`
- `BKASH_APP_KEY`
- `BKASH_APP_SECRET`

The bKash callback URL is generated from Netlify's deployed site URL and points to `/.netlify/functions/bkash-callback`. Register/allowlist this callback URL with bKash if their onboarding process requires it. Use HTTPS and a stable production domain before going live.

Optional email:
- `RESEND_API_KEY`
- `ADMIN_EMAIL`
- `EMAIL_FROM` (verified sender address)

Optional WhatsApp:
- `WHATSAPP_TOKEN`
- `WHATSAPP_PHONE_NUMBER_ID`
- `WHATSAPP_ADMIN_NUMBER` (international digits only)
- `WHATSAPP_TEMPLATE_NAME`
- `WHATSAPP_TEMPLATE_LANGUAGE` (for example `en`)
- `WHATSAPP_API_VERSION` (supported Graph API version)

After changing environment variables, redeploy the site. Netlify documents that Functions can access environment variables at runtime and that values are managed outside the repository: https://docs.netlify.com/build/functions/environment-variables/.

## 3. Payment flow
1. Customer chooses bKash and submits checkout details.
2. `start-bkash-payment` recalculates prices and delivery on the server, stores an order as awaiting payment, then calls bKash Create Payment.
3. Customer is redirected to the `bkashURL` returned by bKash.
4. bKash redirects to `bkash-callback`.
5. The callback executes the payment (or queries it after an uncertain execute result), and checks `transactionStatus`, amount, BDT currency and invoice number against the saved order.
6. Only a matching completed payment changes `payment_status` to `Paid` and order status to `New`. If it cannot be confirmed, the order remains in review.

Relevant functions:
- `netlify/functions/_bkash.mjs`
- `netlify/functions/start-bkash-payment.mjs`
- `netlify/functions/bkash-callback.mjs`

## 4. Test before launch
- Get bKash merchant onboarding and sandbox credentials.
- Confirm the exact API base URL, API version, callback format and required merchant fields with bKash.
- Test success, cancel, failure, insufficient balance, timeout, duplicate callback and delayed callback scenarios in sandbox.
- Confirm amount/currency/invoice mismatch never marks an order paid.
- Confirm Supabase, admin dashboard, email and WhatsApp notifications.
- Switch to production credentials only after bKash approves live access.

## 5. Customize
- Demo products/prices/photos are in `index.html`.
- The server-side catalogue is in `netlify/functions/create-order.mjs` and `netlify/functions/start-bkash-payment.mjs`. Keep product IDs/prices identical.
- Replace the Nagad placeholder in `index.html` with the merchant number you intend customers to use.
- Add your actual NOOR logo and product photography before launch.
- Delivery fee is enforced server-side: `inside` = ৳70; `outside` = ৳140.

## 6. Deploy
1. Push the project folder to a private GitHub repository or deploy with Netlify CLI.
2. Import it in Netlify; publish directory `.` and functions directory `netlify/functions` are already configured.
3. Run the Supabase SQL, configure secrets and deploy.
4. Visit `/admin.html` and log in with `ADMIN_PASSWORD`.
5. Test COD and Nagad; test bKash only after sandbox credentials are configured.

## Security and launch checklist
- Never commit API keys, Supabase service-role keys, bKash credentials, Meta tokens, Resend keys or admin secrets.
- Add rate limiting / bot protection to public order and payment-initiation endpoints before launch.
- Add a privacy policy and business contact information; restrict access to customer orders.
- The current admin login is a basic starter, not enterprise-grade authentication. Use a strong password and consider MFA/managed authentication as the store grows.
- Confirm current bKash technical and commercial terms directly with bKash before accepting live payments.
