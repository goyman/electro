defmodule Electro.Octopart do
  require Logger

  @api_url "https://api.nexar.com/graphql"

  def api_query(q, limit) do
    """
    {
      supSearch(q: "#{q}", limit: #{limit}) {
        results {
          part {
            mpn
            manufacturer {
              name
            }
            descriptions {
              text
            }
            bestDatasheet {
                url
                name
            }
            specs {
              displayValue
              attribute {
                name
              }
            }
          }
        }
      }
    }
    """
  end

  def search(""), do: {:ok, []}
  def search(nil), do: {:ok, []}

  def search(query, limit \\ 5) do
    token = Application.get_env(:electro, :octopart_token)

    if token == nil || token == "" do
      {:error, :no_token}
    else
      query = Jason.encode!(%{query: api_query(query, limit)})

      headers = [
        {"Token", token},
        {"Content-Type", "application/json"},
        {"Accept", "application/json"}
      ]

      HTTPoison.post(@api_url, query, headers)
      |> dbg
      |> case do
        {:ok, %{status_code: 200, body: body}} ->
          body = Jason.decode!(body)
            |> dbg
          {:ok, map_results(body)}

        {:ok, res} ->
          Logger.error("Invalid API result")
          Logger.error(inspect(res))
          {:error, :invalid_result}

        {:error, err} = res ->
          Logger.error("HTTP error")
          Logger.error(inspect(err))
          {:error, :http_error}
      end
    end
  end

  defp map_results(%{"data" => %{"supSearch" => %{"results" => results}}})
       when is_list(results) do
    results
    |> Enum.map(fn %{"part" => part} ->
      %{
        mpn: part["mpn"],
        name: part["mpn"],
        description:
          part["descriptions"]
          |> Enum.map(& &1["text"])
          |> List.first(),
        manufacturer: part["manufacturer"]["name"],
        specs:
          part["specs"]
          |> Enum.map(fn %{
                           "attribute" => %{"name" => key},
                           "displayValue" => value
                         } ->
            {key, value}
          end)
          |> Map.new(),
        documents:
          [part["bestDatasheet"]]
          |> Enum.reject(&is_nil/1)
          |> Enum.map(fn %{"name" => name, "url" => url} ->
            %{name: name, url: url}
          end)
      }
    end)
  end

  defp map_results(_), do: []
end
