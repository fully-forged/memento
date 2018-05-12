# Memento

[![Build Status](https://travis-ci.org/fully-forged/memento.svg?branch=master)](https://travis-ci.org/fully-forged/memento)

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
- a very simple **http api** to serve and search stored content
- a UI (written in [Elm](http://elm-lang.org/))
- a CLI-based UI written in Elixir

### Capture

The capture workflow is structured around two ideas: [Memento.Capture.Feed](https://github.com/fully-forged/memento/blob/master/lib/memento/capture/feed.ex) and [Memento.Capture.Handler](https://github.com/fully-forged/memento/blob/master/lib/memento/capture/handler.ex).

The Feed (implemented as a state machine via [gen_statem](http://erlang.org/doc/design_principles/statem.html)) represents all common steps used to get data from any source:

- Initial authentication (where needed)
- Try to fetch the latest changes
- On success, store the data, wait 5 minutes and try again
- On failure, wait 30 seconds and try again

What changes between two sources is how some specific steps are performed and this where the Handler comes in: defined as a [behaviour](http://elixir-lang.github.io/getting-started/typespecs-and-behaviours.html#behaviours), it’s implemented by every source in their own way, as all APIs are different.

### Storage and search

All entries are stored on Postgresql. For search, we define a `entries_search_index` materialized view where we use Postgresql's full text search functionality. This view is updated via a database trigger (all of this is defined as database migrations, see the [migrations folder](https://github.com/fully-forged/memento/tree/master/priv/repo/migrations) for more details.

### HTTP api

This is implemented via [Plug](https://github.com/elixir-plug/plug), defined in [Memento.API.Router](https://github.com/fully-forged/memento/blob/master/lib/memento/api/router.ex).

The api also uses a custom rate limiter in front of the `refresh` endpoint to avoid incurring into issues due the abuse of the capture-related apis. Its components are:

- a public API module defined in [Memento.RateLimiter](https://github.com/fully-forged/memento/blob/master/lib/memento/rate_limiter.ex)
- an ETS-backed store defined in [Memento.RateLimiter.Store](https://github.com/fully-forged/memento/blob/master/lib/memento/rate_limiter/store.ex)
- a prune worker which resets the store at the configured interval (defined in [Memento.RateLimiter.Prune](https://github.com/fully-forged/memento/blob/master/lib/memento/rate_limiter/prune.ex) and started by [Memento.RateLimiter.Supervisor](https://github.com/fully-forged/memento/blob/master/lib/memento/rate_limiter/supervisor.ex)).
- a rate limiter plug defined in [Memento.API.RateLimiter](https://github.com/fully-forged/memento/blob/master/lib/memento/api/rate_limiter.ex)

### UI

The UI is contained in the [frontend](https://github.com/fully-forged/memento/tree/master/frontend) folder and uses [elm.mk](https://github.com/cloud8421/elm.mk) for compilation/watch. It's served via the parent Elixir application.

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

The project is setup with [Nanobox](https://nanobox.io/). Once you have it installed, you can:

- use `nanobox evar` to setup the environment variables
- use `nanobox run` to open a shell session to the container
- call `nanobox dns add local memento.local` so that you can visit <http://memento.local> to access the UI

Once inside the container you can:

- call `mix do deps.get, ecto.migrate` to fetch elixir dependencies, compile and setup the db.
- call `iex -S mix` to open an iex session with the running project (and then open <http://memento.local>)
- call `MIX_ENV=test mix do ecto.create, ecto.migrate, test` to run tests for the first time (after that, it's only `mix test` )

To work on the UI, open another container session in a different terminal, `cd frontend` and `make watch`. Any change on frontend files will trigger a build, so you just need to refresh the browser to see your changes.

## Deployment

Assuming you have Nanobox setup for deployment, you just need to call `nanobox deploy`. Note that the project is also setup for [Travis.ci](https://travis-ci.org/fully-forged/memento). Note that Travis needs the same environment variables you setup locally to function.

## CLI Utility

Running `mix escript.build` will build a `memento` cli executable in `./bin` (which requires, to be executed, a working Erlang installation on the host machine) that can be used to browse a Memento instance from the command line.

Once built, you can call:

`./bin/memento --base-url https://memento.my-site.com`

For the full range of options, please call `./bin/memento --help`.

Please note that the file can be safely moved and dropped in your `$PATH`.

For ease of using, it's recommended to pipe the command to `less -r`, which will paginate the results in glorious full colour.

`./bin/memento --base-url https://memento.my-site.com | less -r`
