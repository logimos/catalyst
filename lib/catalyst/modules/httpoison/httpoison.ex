defmodule Catalyst.Modules.Httpoison do

  @moduledoc """
  Configures HTTPoison for HTTP requests in the Phoenix application.
  """
  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:httpoison, "~> 2.0"})
    create_http_client(project_path)
    create_http_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_http_client(project_path) do
    app_name = Path.basename(project_path)
    clients_dir = Path.join([project_path, "lib", app_name, "clients"])
    File.mkdir_p!(clients_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(clients_dir, "http_client.ex", """
    defmodule #{app_module}.Clients.HttpClient do
      @moduledoc \"\"\"
      HTTP client using HTTPoison for external API requests.
      \"\"\"

      @headers [{"Content-Type", "application/json"}, {"User-Agent", "#{app_module}/1.0"}]

      def get(url, headers \\\\ []) do
        HTTPoison.get(url, @headers ++ headers) |> handle_response()
      end

      def post(url, body, headers \\\\ []) do
        HTTPoison.post(url, Jason.encode!(body), @headers ++ headers) |> handle_response()
      end

      def put(url, body, headers \\\\ []) do
        HTTPoison.put(url, Jason.encode!(body), @headers ++ headers) |> handle_response()
      end

      def delete(url, headers \\\\ []) do
        HTTPoison.delete(url, @headers ++ headers) |> handle_response()
      end

      def patch(url, body, headers \\\\ []) do
        HTTPoison.patch(url, Jason.encode!(body), @headers ++ headers) |> handle_response()
      end

      defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
        case Jason.decode(body) do
          {:ok, json} -> {:ok, json}
          _ -> {:ok, body}
        end
      end

      defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
        {:error, %{status: code, body: body}}
      end

      defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
        {:error, %{reason: reason}}
      end
    end
    """)
  end

  defp create_http_documentation(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)

    markdown_content = """
    # HTTPoison HTTP Client Integration

    Catalyst has integrated HTTPoison into your Phoenix project for external HTTP requests.

    ## Changes Made:
    - Added `HTTPoison` to dependencies in `mix.exs`
    - Created HTTP client module at `lib/#{app_name}/clients/http_client.ex`

    ## Basic Usage Example:

    ```elixir
    alias #{app_module}.Clients.HttpClient

    # GET request example
    case HttpClient.get("https://api.example.com/data") do
      {:ok, data} -> IO.inspect(data)
      {:error, error} -> IO.inspect(error)
    end
    ```

    ## Supported Methods:
    - GET, POST, PUT, DELETE, PATCH with automatic JSON handling.

    """

    create_documentation(project_path, "httpoison", markdown_content)  end

end
