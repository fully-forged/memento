defmodule Memento.Template do
  @static_path Path.join([
                 :code.priv_dir(:memento),
                 "static",
                 to_string(Mix.env())
               ])

  @index_html Path.join(@static_path, "index.html")
              |> File.read!()

  def index, do: @index_html
end
