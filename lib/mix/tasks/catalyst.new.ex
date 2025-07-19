defmodule Mix.Tasks.Catalyst.New do
  use Mix.Task

  @shortdoc "Interactive modular setup for Phoenix projects with Catalyst"

  def run(_) do
    Mix.shell().info("🚀 Welcome to Catalyst - Modular Phoenix Setup!")

    project_name = get_project_name()
    db_option = get_database_choice()

    modules = [
      {:oban, "Include Oban (background jobs)?"},
      {:auth, "Include Authentication (phx_gen_auth)?"},
      {:liveview, "Include LiveView with examples?"},
      {:bodyguard, "Include Bodyguard (authorization)?"},
      {:absinthe, "Include Absinthe (GraphQL)?"},
      {:waffle, "Include Waffle (file uploads)?"},
      {:httpoison, "Include HTTPoison (HTTP requests)?"},
      {:swoosh, "Include Swoosh (email)?"},
      {:ex_machina, "Include ExMachina (test factories)?"},
      {:credo, "Include Credo (code quality)?"},
      {:dialyxir, "Include Dialyxir (static analysis)?"},
      {:alpine, "Include Alpine.js?"},
      {:docker, "Include Docker support?"}
    ]

    selected_modules = Enum.filter(modules, fn {_, question} ->
      Mix.shell().yes?("#{question} [Yn] ")
    end)

    command = "mix phx.new #{project_name} #{db_option} --tailwind"
    Mix.shell().info("Running command: #{command}")

    case System.cmd("sh", ["-c", command]) do
      {_output, 0} ->
        Mix.shell().info("✅ Phoenix project created successfully!")
        setup_modules(project_name, selected_modules)
      {error, _} ->
        Mix.shell().error("❌ Failed to create Phoenix project: #{error}")
        System.halt(1)
    end
  end

  defp get_project_name() do
    project_name = Mix.shell().prompt("Project name? ") |> String.trim()

    cond do
      project_name == "" ->
        Mix.shell().error("Project name cannot be empty")
        get_project_name()
      not valid_project_name?(project_name) ->
        Mix.shell().error("Invalid project name. Use only lowercase letters, numbers, and underscores")
        get_project_name()
      File.exists?(project_name) ->
        Mix.shell().error("Directory '#{project_name}' already exists")
        get_project_name()
      true ->
        project_name
    end
  end

  defp valid_project_name?(name) do
    String.match?(name, ~r/^[a-z][a-z0-9_]*$/)
  end

  defp get_database_choice() do
    db_choice = Mix.shell().prompt("Database [1] Postgres (default), [2] MySQL, [3] SQLite: ") |> String.trim()

    case db_choice do
      "2" -> "--database mysql"
      "3" -> "--database sqlite3"
      _ -> "--database postgres"
    end
  end

  defp setup_modules(project_name, selected_modules) do
    project_path = Path.expand(project_name)

    Enum.each(selected_modules, fn {module, _} ->
      module_name = Module.concat(Catalyst.Modules, Macro.camelize(to_string(module)))

      case apply(module_name, :setup, [project_path]) do
        :ok ->
          Mix.shell().info("✅ #{Macro.camelize(to_string(module))} setup completed!")
        {:error, reason} ->
          Mix.shell().error("❌ #{Macro.camelize(to_string(module))} setup failed: #{reason}")
      end
    end)

    Mix.shell().info("\n🎉 Catalyst setup is complete! Navigate to your project with:")
    Mix.shell().info("  cd #{project_name}")
    Mix.shell().info("  mix setup")
  end
end
