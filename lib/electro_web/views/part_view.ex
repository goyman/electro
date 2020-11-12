defmodule ElectroWeb.PartView do
  use ElectroWeb, :view

  def map_categories(categories) do
    categories
    |> Enum.map(fn c ->
      name = String.duplicate(" ", c.depth) <> " " <> c.name

      [key: name, value: c.id]
    end)
  end
end
