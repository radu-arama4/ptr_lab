# TweetProcesser

Laboratory work for PTR course.
System for tweet processing and storing to database.

It uses the actor model in order to handle the concurrency.

Implemented functionalities:
- Autoscalling
- Load balancing
- Supervision
- Parameterizable worker pools
- Database storing

For system overview (Supervision tree and System architecture) see <em>_docs</em>.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tweet_processer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tweet_processer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tweet_processer](https://hexdocs.pm/tweet_processer).
