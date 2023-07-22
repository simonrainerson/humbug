# 🐞 Humbug

Humbug is a chat app, where discussion takes place in topics. Topics are grouped into rooms, and a
topic can appear in multiple rooms.

⚠️ This project is used to learn and expermient with elixir, use at your own risk! ⚠️

## Development
This project uses [devenv](https://devenv.sh/getting-started/) to set up a development environment.
After installing nix, cachix and devenv, run `devenv up` to start the database and `devenv shell` to
get a shell with elixir and its language server and handy scripts to do things.

### Without devenv
Install elixir in some way, then to start the server:
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
