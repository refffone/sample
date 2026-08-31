# Receiving Log

A $0 Cloudflare Worker that lets a warehouse worker log a material receipt and a
quality chemist see it and mark it checked, from any browser with the URL — no
software installed on either PC. Runs on Cloudflare's free tier (Workers + D1).

## What's already provisioned

- A live D1 database, `receiving-log-db` (id `6003a115-51c6-4261-bb26-ae88b38644b9`),
  with the `receipts` and `push_subscriptions` tables already created (see
  `schema.sql`).
- The database is empty and ready to use — nothing else to run.
- A VAPID key pair for push notifications has already been generated (used
  below in step 5) — the public key is baked into `src/index.js`.

## What's left: deploying the Worker

The MCP tools available in this session can create/query D1, but can't deploy a
Worker script directly, so this last step needs ~5 minutes in the Cloudflare
dashboard (free account, no installs):

1. Go to **dash.cloudflare.com** → sign up free if you don't have an account.
2. **Workers & Pages** → **Create** → **Create Worker**. Name it `receiving-log`
   (or anything) → **Deploy** (it'll deploy a placeholder first).
3. Click **Edit code**. Delete everything in the editor and paste the full
   contents of `src/index.js` from this folder. Click **Deploy**.
4. Bind the database: on the Worker's page → **Settings** → **Bindings** →
   **Add binding** → **D1 database**. Variable name: `DB`. Database:
   `receiving-log-db`. Save.
5. Add the secrets: same **Settings** → **Variables and Secrets** → **Add**,
   five times, each type **Secret**:
   - `WAREHOUSE_PASSWORD` — the password warehouse staff will use
   - `QUALITY_PASSWORD` — the password quality staff will use
   - `AUTH_SECRET` — any long random string (used to sign login tokens, not
     shown to users — e.g. mash the keyboard for 40 characters)
   - `VAPID_PRIVATE_KEY_JWK` — paste exactly this (it's the private half of
     the push-notification key pair, already generated for this project):
     ```
     {"key_ops":["sign"],"ext":true,"kty":"EC","x":"ftkaglP5KyL0Fy8qvfkbnOOZzKqXOYKqx52HOFdFk8M","y":"pCLTVJ1vKrUXAWTARrpWdz1Zcfcdn4UTqGlSGNNFScE","crv":"P-256","d":"o7vtQXP3VItX1P-Hh9G3IPADnR0Hz8P-xaeHnCO3WD4"}
     ```
   - `VAPID_SUBJECT` — `mailto:` plus a real contact address at your company
     (e.g. `mailto:quality@4mcoatings.example`). Push services only use this
     to reach you if deliveries are failing; it's never shown to users.
6. Add the cleanup schedule: **Settings** → **Triggers** → **Cron Triggers** →
   **Add Cron Trigger** → `0 * * * *` (runs hourly, purges anything checked
   more than 24h ago). Save.
7. Your live URL is shown at the top of the Worker's page, something like
   `https://receiving-log.<your-subdomain>.workers.dev`. That's the 24/7 URL —
   bookmark it on both PCs. It stays up whether either PC is on or off.

## Using it

- Open the URL, sign in with the Warehouse or Quality password — the app
  figures out which role you are from which password matched.
- Warehouse signs in and logs receipts; Quality signs in and sees Pending /
  Recently Checked, with a one-tap "Mark Checked" button.
- Checked records auto-clear 24h after being checked, so storage never grows.

### Installing it as a phone icon

An **"Add to Home Screen"** button is built into the app itself (top-right of
the login screen and the app header). On Android/Chrome/Edge it triggers the
browser's native install prompt directly. On iPhone/iPad (Safari doesn't
support triggering this programmatically) it instead shows a small banner
with the manual steps: tap Share → "Add to Home Screen". Either way it adds a
real app icon that opens the page full-screen — the closest $0, no-install
equivalent to a native "widget." It won't show live data on the home screen
the way an OS widget would (that needs a real native app), but it opens
instantly like an app.

### Push notifications for Quality

When a receipt is logged, everyone currently signed in as Quality who has
granted notification permission gets a push notification ("A new receipt was
logged and is pending your check.") even if the app isn't open — standard Web
Push, no Firebase/Google account, no paid service. The browser asks for
notification permission automatically the first time someone signs in as
Quality.

Two things worth knowing:

- **iPhone requirement**: iOS only delivers web push to a site that's been
  added to the Home Screen (iOS 16.4+) — a normal Safari tab won't get
  notifications. This is exactly what the install button above is for, so on
  iPhone, install first, then open the app *from the home screen icon* and
  sign in as Quality there.
- The notification text is generic (it doesn't include the material code or
  supplier) — this avoids a much larger implementation (encrypting the push
  payload per RFC 8291). Tapping the notification opens the app, where the
  Pending list has the details.

## Local files

- `src/index.js` — the entire Worker: page, API, and login logic in one file.
- `schema.sql` — the D1 schema (already applied to the live database).
- `wrangler.toml` — reference config if you ever want to switch to deploying
  via the `wrangler` CLI instead of the dashboard (needs Node installed
  somewhere — not required for day-to-day use by either PC).
