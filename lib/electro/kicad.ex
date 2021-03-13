defmodule Electro.Kicad do
  def load_file(file_path) do
    with {:ok, data} <- File.read(file_path) do
      {:ok, load(data)}
    else
      err -> err
    end
  end

  def load(data) do
    Electro.SExprs.sexprs(data)
    |> extract_symbols()
  end

  def extract_symbols({:ok, [content | _], _, _, _, _}) do
    content
    |> Enum.filter(fn e ->
      case e do
        ["symbol" | fields] -> true
        _ -> false
      end
    end)
    |> Enum.map(fn e ->
      e
      |> Enum.reduce(%{}, fn props, res ->
        case props do
          ["property", "Reference", ref | _] -> Map.put(res, :ref, ref)
          ["property", "Value", val | _] -> Map.put(res, :val, val)
          ["property", "IPN", ipn | _] -> Map.put(res, :ipn, ipn)
          ["property", "MPN", mpn | _] -> Map.put(res, :mpn, mpn)
          _ -> res
        end
      end)
    end)
  end
end
