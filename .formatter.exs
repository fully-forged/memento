# Used by "mix format"
[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 80,
  locals_without_parens: [
    # plug, plug_rest
    plug: 1,
    plug: 2,
    resource: 2,
    resource: 3,
    match: 2,
    # ecto
    from: 2
  ]
]
