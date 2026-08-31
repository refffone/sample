# Receiving Log

A $0 Cloudflare Worker that lets a warehouse worker log a material receipt and a
quality chemist see it and mark it checked, from any browser with the URL — no
software installed on either PC. Runs on Cloudflare's free tier (Workers + D1).

## What's already provisioned

- A live D1 database, `receiving-log-db` (id `6003a115-51c6-4261-bb26-ae88b38644b9`),
  with the `receipts` table already created (see `schema.sql`).
- The database is empty and ready to use — nothing else to run.

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
5. Add the passwords: same **Settings** → **Variables and Secrets** → **Add**,
   three times, each type **Secret**:
   - `WAREHOUSE_PASSWORD` — the password warehouse staff will use
   - `QUALITY_PASSWORD` — the password quality staff will use
   - `AUTH_SECRET` — any long random string (used to sign login tokens, not
     shown to users — e.g. mash the keyboard for 40 characters)
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

On a phone browser (Chrome/Edge on Android, Safari on iOS), open the URL, then
use the browser's **"Add to Home Screen" / "Install app"** option. This adds a
proper app icon that opens the page full-screen — the closest $0, no-install
equivalent to a native "widget." It won't show live data on the home screen
the way an OS widget would (that needs a real native app), but it opens
instantly like an app and works the same on the warehouse/quality PCs' browsers
too.

## Local files

- `src/index.js` — the entire Worker: page, API, and login logic in one file.
- `schema.sql` — the D1 schema (already applied to the live database).
- `wrangler.toml` — reference config if you ever want to switch to deploying
  via the `wrangler` CLI instead of the dashboard (needs Node installed
  somewhere — not required for day-to-day use by either PC).
