defmodule ElectroWeb.PartLive.Index do
  use Phoenix.LiveView,
    container: {:div, class: "max-h-full flex w-full max-w-full h-full"}

  alias ElectroWeb.Router.Helpers, as: Routes
  use Phoenix.HTML

  alias Electro.Inventory
  alias Electro.Octopart

  def init(socket) do
    assign(socket,
      results: [],
      selected_category: nil,
      query: nil,
      selected_part: nil
    )
  end

  def mount(_params, _, socket) do
    categories = Inventory.categories()
    {:ok, assign(init(socket), categories: categories)}
  end

  def handle_params(%{"cat_id" => id}, _url, socket) do
    cat = Inventory.category(id)
    res = Inventory.parts_in_category(id)

    {:noreply, assign(socket, selected_category: cat, results: res, query: nil)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("save_part", %{"part" => params}, socket) do
    part =
      socket.assigns.selected_part
      |> Map.merge(%{
        name: params["name"],
        mpn: params["mpn"],
        location: params["location"],
        description: params["description"],
        stock: params["stock"]
      })

    {:ok, part} = Inventory.save_part(part)

    res =
      socket.assigns.selected_category
      |> case do
        nil -> []
        cat -> Inventory.parts_in_category(cat.id)
      end

    {:noreply, assign(socket, selected_part: part, results: res)}
  end

  def handle_event("move_part", %{"part" => %{"category_id" => cid}}, socket) do
    part = socket.assigns.selected_part

    {:ok, part} = Inventory.move_part(part, cid)

    {:noreply, assign(socket, selected_part: part)}
  end

  def handle_event("search", %{"q" => q}, socket) do
    res = Inventory.parts_with_query(q)

    {:noreply, assign(socket, selected_category: nil, results: res, query: q)}
  end

  def handle_event("select_part", %{"id" => id}, socket) do
    part = Inventory.part_with_id(id)
    {:noreply, assign(socket, selected_part: part)}
  end

  def handle_event("open_file", %{"path" => path}, socket) do
    {:ok, path} = Base.decode64(path)
    # TODO allow configuration of that command
    System.cmd("rifle", [path])
    {:noreply, socket}
  end

  def handle_event("open_folder", _, socket) do
    # TODO allow configuration of that command
    part = socket.assigns.selected_part
    path = Path.dirname(part.path)
    System.cmd("xdg-open", [path])
    {:noreply, socket}
  end

  def handle_event("add_part", _, socket) do
    path =
      Routes.part_add_path(socket, :index, socket.assigns.selected_category.id)

    {:noreply, redirect(socket, to: path)}
  end

  def handle_event("add_category", _, socket) do
    path =
      Routes.category_add_path(
        socket,
        :index,
        socket.assigns.selected_category.id
      )

    {:noreply, redirect(socket, to: path)}
  end

  def handle_event("print_label", _, socket) do
    part = socket.assigns.selected_part
    Electro.Pdf.print_part_label(part)
    {:noreply, socket}
  end

  def handle_event("open_category", _, socket) do
    part = socket.assigns.selected_part
    cat = Inventory.category(part.category_id)
    res = Inventory.parts_in_category(part.category_id)

    {:noreply, assign(socket, selected_category: cat, results: res, query: nil)}
  end


  def map_categories(categories) do
    categories
    |> Enum.map(fn c ->
      name = String.duplicate(" ", c.depth) <> " " <> c.name

      [key: name, value: c.id]
    end)
  end
end
