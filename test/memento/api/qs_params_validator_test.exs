defmodule Memento.API.QsParamsValidatorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Memento.API.QsParamsValidator, as: Validator
  doctest Validator

  test "it applies defaults" do
    assert {:ok, %{page: 1, per_page: 25, type: :all, q: :not_provided}} ==
             Validator.validate(%{})
  end

  describe "page and per_page" do
    property "allows page and per page integer strings" do
      check all page_string <- pagination_params_generator(),
                per_page_string <- pagination_params_generator() do
        params = %{"page" => page_string, "per_page" => per_page_string}

        assert {:ok, %{page: page, per_page: per_page}} = Validator.validate(params)

        assert is_integer(page)
        assert is_integer(per_page)
      end
    end

    test "fails for non-numeric values" do
      assert {:error, _} = Validator.validate(%{"page" => "foo"})
      assert {:error, _} = Validator.validate(%{"per_page" => "foo"})
    end
  end

  defp pagination_params_generator do
    StreamData.map(StreamData.integer(), &Integer.to_string/1)
  end

  describe "type" do
    test "parses type" do
      params = %{"type" => "twitter_fav"}

      assert {:ok, %{type: :twitter_fav}} = Validator.validate(params)
    end

    test "fails for non-existing types" do
      params = %{"type" => "non-existing-type"}

      assert {:error, _} = Validator.validate(params)
    end
  end

  describe "q" do
    test "parses q" do
      params = %{"q" => "elixir"}

      assert {:ok, %{q: "elixir"}} = Validator.validate(params)
    end

    test "fails for non-string q" do
      params = %{"q" => []}

      assert {:error, _} = Validator.validate(params)
    end
  end
end
