# Tracker2x2

A 2 by 2 decision matrix using [Pivotal Tracker's](https://www.pivotaltracker.com) API.
Allows a user to prioritize an epic based on urgency and importance.

You'll need to sign in and provide a Pivotal Tracker token.

# Live demo!
You can visit [https://tracker2x2.herokuapp.com](https://tracker2x2.herokuapp.com) to see a live demo

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Update `dev.exs` with the correct postgres user credentials
  * Provide the correct environment variables (see below)
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Environment variables

You'll need to export the following environment variables:

* Google OAuth config (you'll need to configure an OAuth application):
  * GOOGLE_CLIENT_ID
  * GOOGLE_CLIENT_SECRET
  * GOOGLE_REDIRECT_URI

* GitHub OAuth config (to allow for GitHub login):
  * GITHUB_CLIENT_ID
  * GITHUB_CLIENT_SECRET
  * GITHUB_REDIRECT_URI

* Application keys (should be base64 encoded secrets):
  * CLOAK_KEY
  * APP_SALT
  * SECRET_KEY_BASE

* integration test data (to run the live Pivotal Tracker integration tests):
  * TRACKER_API_TOKEN
  * TRACKER_TEST_PROJECT_ID=

Using environment variables is the recommended configuration path for [Twelve-Factor Apps](https://12factor.net/).
This is also the recommended approach for applications that will be deployed to Heroku.
