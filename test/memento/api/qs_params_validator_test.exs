defmodule Memento.API.QsParamsValidatorTest do
  use ExUnit.Case, async: true

  alias Memento.API.QsParamsValidator, as: Validator

  test "it applies defaults" do
    assert {:ok, %{page: 1, per_page: 25, type: :all}} ==
             Validator.validate(%{})
  end

  describe "page" do
    test "parses page" do
      params = %{"page" => "8"}

      assert {:ok, %{page: 8}} = Validator.validate(params)
    end

    test "fails for non-numeric values" do
      params = %{"page" => "foo"}

      assert {:error, _} = Validator.validate(params)
    end
  end

  describe "per_page" do
    test "parses per_page" do
      params = %{"per_page" => "8"}

      assert {:ok, %{per_page: 8}} = Validator.validate(params)
    end

    test "fails for non-numeric values" do
      params = %{"per_page" => "foo"}

      assert {:error, _} = Validator.validate(params)
    end
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
end
