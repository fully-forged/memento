defmodule Memento.Template do
  @static_path Path.join([:code.priv_dir(:memento), "static"])
  @namespace Application.get_env(:memento, :assets_namespace)

  @index_html_path Path.join([@static_path, @namespace, "index.html"])
  @index_html_content File.read!(@index_html_path)

  def index, do: @index_html_content
end
