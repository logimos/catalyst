defmodule Catalyst.Modules.Utils do
  @moduledoc """
  Common utility functions for Catalyst modules.
  """

  def create_file_from_template(dir, file_name, content) do
    file_path = Path.join(dir, file_name)
    unless File.exists?(file_path) do
      File.mkdir_p!(dir)
      File.write!(file_path, content)
    end
  end

  def inject_dependencies(project_path, dependencies) when is_list(dependencies) do
    mix_exs = Path.join(project_path, "mix.exs")
    content = File.read!(mix_exs)

    updated_content =
      Enum.reduce(dependencies, content, fn dep, acc ->
        dep_string = inspect(dep)
        unless String.contains?(acc, dep_string) do
          String.replace(acc, "defp deps do", "defp deps do\n    #{dep_string},")
        else
          acc
        end
      end)

    File.write!(mix_exs, updated_content)
  end

  def inject_dependency(project_path, dependency) do
    inject_dependencies(project_path, [dependency])
  end

  def create_documentation(project_path, module_name, markdown_content) do
    docs_path = Path.join(project_path, "docs/catalyst")
    create_file_from_template(docs_path, "#{module_name}.md", markdown_content)
  end
end
