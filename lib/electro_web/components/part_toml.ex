defmodule ElectroWeb.PartTOML do

  def part(assigns) do
    EEx.eval_string(
    """
    id = <%= inspect(@part.id) %>
    name = <%= inspect(Map.get(@part, :name, "")) %>
    location = <%= inspect(Map.get(@part, :location, "")) %>
    mpn = <%= inspect(Map.get(@part, :mpn, "")) %>
    stock = <%= inspect(Map.get(@part, :stock, 0)) %>
    description = <%= inspect(Map.get(@part, :description, "")) %>

    <%= if @part[:specs] do %>
    [specs]
    <%= for {k, v} <- @part.specs do %><%= inspect(k) %> = <%= inspect(v) %>
    <% end %>
    <% end %>
    """, assigns: assigns)
  end
end
