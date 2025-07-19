defmodule Catalyst.Modules.Absinthe do
  @moduledoc """
  Configures Absinthe GraphQL for the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependencies: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependencies(project_path, [
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0"}
    ])
    create_graphql_schema(project_path)
    create_resolvers(project_path)
    update_router(project_path)
    create_absinthe_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_graphql_schema(project_path) do
    app_name = Path.basename(project_path)
    graphql_dir = Path.join([project_path, "lib", app_name, "graphql"])
    File.mkdir_p!(graphql_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(graphql_dir, "schema.ex", """
    defmodule #{app_module}.GraphQL.Schema do
      use Absinthe.Schema
      import_types #{app_module}.GraphQL.Types

      query do
        field :hello, :string do
          resolve(fn _, _, _ -> {:ok, "Hello from GraphQL!"} end)
        end
      end
    end
    """)

    create_file_from_template(graphql_dir, "types.ex", """
    defmodule #{app_module}.GraphQL.Types do
      use Absinthe.Schema.Notation

      object :user do
        field :id, :id
        field :name, :string
        field :email, :string
        field :inserted_at, :naive_datetime
        field :updated_at, :naive_datetime
      end
    end
    """)
  end

  defp create_resolvers(project_path) do
    app_name = Path.basename(project_path)
    resolvers_dir = Path.join([project_path, "lib", app_name, "graphql", "resolvers"])
    File.mkdir_p!(resolvers_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(resolvers_dir, "user_resolver.ex", """
    defmodule #{app_module}.GraphQL.Resolvers.UserResolver do
      @moduledoc \"\"\"
      Resolver for user queries and mutations.
      \"\"\"

      def get_user(%{id: id}, _), do: {:ok, %{id: id, name: "User \#{id}", email: "user\#{id}@example.com"}}
      def list_users(_, _), do: {:ok, [%{id: "1", name: "John Doe", email: "john@example.com"}]}
    end
    """)
  end

  defp update_router(project_path) do
    app_name = Path.basename(project_path)
    router_file = Path.join([project_path, "lib", "#{app_name}_web", "router.ex"])
    content = File.read!(router_file)
    app_module = Macro.camelize(app_name)

    graphql_routes = """
      # GraphQL endpoints
      forward "/graphql", Absinthe.Plug, schema: #{app_module}.GraphQL.Schema
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: #{app_module}.GraphQL.Schema
    """

    unless String.contains?(content, "/graphql") do
      updated_content = String.replace(content, "scope \"/\", #{app_module}Web do", "scope \"/\", #{app_module}Web do\n#{graphql_routes}")
      File.write!(router_file, updated_content)
    end
  end

  defp create_absinthe_documentation(project_path) do
    app_name = Path.basename(project_path)

    content = """
    # Absinthe GraphQL Integration

    Catalyst has integrated Absinthe GraphQL into your Phoenix application.

    ## Changes Made:
    - Added Absinthe dependencies in `mix.exs`
    - GraphQL schema created at `lib/#{app_name}/graphql/schema.ex`
    - Resolvers set up under `lib/#{app_name}/graphql/resolvers/`
    - GraphQL endpoints added to your router

    ## Usage:
    GraphQL endpoint available at `/graphql`.
    Interactive playground (GraphiQL) available at `/graphiql`.

    Example query:
    ```graphql
    query {
      hello
    }
    ```
    """

    create_documentation(project_path, "absinthe", content)
  end
end
