defmodule ElectroWeb.LabelController do
  use ElectroWeb, :controller
  alias Electro.Inventory

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def print(conn, %{"label" => label}) do
    {text, opts} = Map.pop(label, "text")

    opts =
      case opts do
        %{"fit" => "true"} -> %{fit: true}
        _ -> %{}
      end

    Electro.Pdf.print_text_label(text, opts)
    render(conn, "index.html")
  end
end
