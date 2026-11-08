# RunBaza API

TypeScript and Hono with SQLite. This server is an original implementation of the
contract described in Lab 5. It is not copied from the course kit. The included
58 HTTP checks are project tests; the separate course conformance suite has not
been provided or executed.

## Start

Requires Node.js 24 or newer and pnpm 11.25.0.

```sh
cd ~/Desktop/PAM/Lab2/server
pnpm install --frozen-lockfile
pnpm start
```

On a Mac without these tools, install Node.js and pnpm first. With Homebrew:
`brew install node pnpm`. Keep Node.js on version 24 or newer.

The API listens at `http://127.0.0.1:8080`. SQLite creates `data/app.db` on first
start. Restarting preserves accounts, plans, trips and profile settings. The
initial 28 races are demonstration data, not current event announcements.
No account or password is preconfigured. Register from the application.

Configuration: `PORT`, `HOST`, `DB_PATH`, `JWT_SECRET`. The `.env.example` file is
a reference; variables must be exported by the shell. For example:

```sh
JWT_SECRET=another-lab-secret pnpm start
```

Changing the secret invalidates existing JWTs. On the next protected request,
Flutter clears the token and returns to login. A running server must be stopped
with Ctrl+C before starting its replacement on the same port.

## Contract

| Endpoint | Behavior |
| --- | --- |
| GET /health | Public health check |
| POST /auth/register | email, password (8+ chars), name; returns 201 with token and user |
| POST /auth/login | email, password; returns 200 with token and user |
| /notes | Reference CRUD resource |
| /races | Shared seeded catalog plus the user's own races |
| /plans | One private participation record per user and race |
| /offers | Private driver offers for this lab |
| /requests | Private passenger requests for this lab |
| /profiles | Profile created with registration; editable through PUT |
| POST /files | Authenticated multipart file, maximum 5 MiB |
| GET /files/:id | Owner-only download, attachment and restrictive headers |

Every collection supports GET/POST; each `/:id` supports GET/PUT/DELETE.
Create returns 201, read/update 200, delete 204 with an empty body. IDs are assigned
by the server. A second profile returns 409; registration already creates one.
Seeded public races are read-only. All other objects are scoped to the account;
accessing another account's private ID returns 404.

Lists return `{items, page, limit, total}`. Query parameters are `page` (default 1),
`limit` (default 20, maximum 100) and `search`. `/races` additionally accepts
`country=moldova|romania`. Search executes in SQLite against normalized text,
including Unicode city names. Values are bound parameters, not SQL fragments.

Errors use `{error:{code,message}}` with VALIDATION_ERROR, UNAUTHORIZED,
EMAIL_TAKEN, NOT_FOUND, CONFLICT or INTERNAL_ERROR. Flutter translates codes into
Russian. Server English error prose is never shown directly.

## Checks

```sh
pnpm check
pnpm test
# Optional: check an already running server with separate test accounts.
pnpm conformance
```

`pnpm test` starts a real HTTP server on a temporary port, runs 58 contract checks,
then separately verifies disk persistence and JWT secret rotation. It does not
change the development database.

`test/ios_controller.ts` is a localhost-only integration fixture. It exposes API
port 8090 and test commands on 8091 for stopping/restarting the API during iOS
checks. It is never imported by `src/index.ts` or used by `pnpm start`.

## Scope

Passwords use a random salt and scrypt; JWT signatures use HS256 and expire after
24 hours. This is a local teaching server with a known default secret and open
CORS. It has no production deployment, rate limiting, password recovery, email
verification or token revocation service. Logout removes the local token.
Offers and requests are private records, not a public marketplace or confirmed
bookings. Upload is implemented and checked at API level; the current RunBaza UI
uses generated route artwork and has no file picker requirement.
