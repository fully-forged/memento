# Memento

## Intro

Memento is a single-tenant, personal aggregator for information you “save” on different platforms, making that content searchable and partially backed up. Aggregation is automatic every 5 minutes.

![Memento Screenshot](https://raw.githubusercontent.com/fully-forged/memento/master/screenshot.png)

It currently supports:

- Twitter favourites
- Instapaper articles
- Pinboard bookmarks
- GitHub starred repositories

All data gets saved in a single Postgresql table (for easy search and backup).

The application scope is small, but one of the goals is to make it extremely robust, with all bells and whistles you need for production code.

## Application structure

Memento has four main components:

- a **capture** supervision tree, where every source of content is monitored via a feed process
- **permanent storage** powered by Ecto and Postgresql
- a UI powered by Phoenix
- a CLI-based UI written in Elixir

### Capture

The capture workflow is structured around two ideas: [Memento.Capture.Feed](https://github.com/fully-forged/memento/blob/master/lib/memento/capture/feed.ex) and [Memento.Capture.Handler](https://github.com/fully-forged/memento/blob/master/lib/memento/capture/handler.ex).

The Feed (implemented as a state machine via [gen_statem](http://erlang.org/doc/design_principles/statem.html)) represents all common steps used to get data from any source:

- Initial authentication (where needed)
- Try to fetch the latest changes
- On success, store the data, wait 5 minutes and try again
- On failure, wait 30 seconds and try again

What changes between two sources is how some specific steps are performed and this where the Handler comes in: defined as a [behaviour](http://elixir-lang.github.io/getting-started/typespecs-and-behaviours.html#behaviours), it’s implemented by every source in their own way, as all APIs are different.

The [Memento.Capture](https://github.com/fully-forged/memento/blob/master/lib/memento/capture.ex) module provides a top level api for manual operations (e.g. forcing a refresh). 

### Storage and search

All entries are stored on Postgresql. 

## Configuration

Please check [`config/config.exs`](https://github.com/fully-forged/memento/blob/master/config/config.exs), configuration options are documented there.

## Documentation

A copy of the documentation is available at <https://memento-docs.surge.sh>.

## Development

You will need a series of environment variables (for authentication against the sources APIs).

- `INSTAPAPER_USERNAME`
- `INSTAPAPER_PASSWORD`
- `INSTAPAPER_OAUTH_CONSUMER_KEY`
- `INSTAPAPER_OAUTH_CONSUMER_SECRET`
- `PINBOARD_API_TOKEN`
- `TWITTER_CONSUMER_KEY`
- `TWITTER_CONSUMER_SECRET`

Once inside the container you can:

- call `mix do deps.get, ecto.migrate` to fetch elixir dependencies, compile and setup the db.
- call `iex -S mix phx.server` to open an iex session with the running project (and then open <http://localhost:4000>)
- call `mix test` to run tests

## Deployment

The project is setup to deploy on Heroku, please make sure you:

- configure environment variables
- provision a Postgresql database add-on
- add the buildpacks detailed at <https://hexdocs.pm/phoenix/heroku.html>

## CLI Utility

Running `mix escript.build` will build a `memento` cli executable in `./bin` (which requires, to be executed, a working Erlang installation on the host machine) that can be used to browse a Memento instance from the command line.

Once built, you can call:

`./bin/memento --base-url https://memento.my-site.com`

For the full range of options, please call `./bin/memento --help`.

Please note that the file can be safely moved and dropped in your `$PATH`.

For ease of using, it's recommended to pipe the command to `less -r`, which will paginate the results in glorious full colour.

`./bin/memento --base-url https://memento.my-site.com | less -r`
