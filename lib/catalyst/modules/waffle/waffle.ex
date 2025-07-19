defmodule Catalyst.Modules.Waffle do
  import Catalyst.Modules.Utils, only: [create_file_from_template: 3]

  @moduledoc """
  Configures Waffle for file uploads in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependencies: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependencies(project_path, [
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.8"}
    ])
    create_uploader(project_path)
    create_upload_controller(project_path)
    create_upload_templates(project_path)
    update_router(project_path)
    create_waffle_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_uploader(project_path) do
    app_name = Path.basename(project_path)
    uploaders_dir = Path.join([project_path, "lib", app_name, "uploaders"])
    File.mkdir_p!(uploaders_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(uploaders_dir, "file_uploader.ex", """
    defmodule #{app_module}.Uploaders.FileUploader do
      use Waffle.Definition
      use Waffle.Ecto.Definition

      @versions [:original, :thumb, :medium]

      def validate({file, _}) do
        Enum.member?(~w(.jpg .jpeg .png .gif .pdf .doc .docx), Path.extname(file.file_name))
      end

      def transform(:thumb, _) do
        {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100"}
      end

      def transform(:medium, _) do
        {:convert, "-strip -thumbnail 300x300^ -gravity center -extent 300x300"}
      end

      def filename(version, {file, _scope}) do
        "\#{version}_\#{file.file_name}"
      end

      def storage_dir(_, _), do: "uploads"
    end
    """)
  end

  defp create_upload_controller(project_path) do
    app_name = Path.basename(project_path)
    controllers_dir = Path.join([project_path, "lib", "#{app_name}_web", "controllers"])
    File.mkdir_p!(controllers_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(controllers_dir, "upload_controller.ex", """
    defmodule #{app_module}Web.UploadController do
      use #{app_module}Web, :controller

      alias #{app_module}.Uploaders.FileUploader

      def index(conn, _params) do
        files = [] # Fetch uploaded files from storage or database
        render(conn, :index, files: files)
      end

      def new(conn, _params), do: render(conn, :new)

      def create(conn, %{"upload" => %{"file" => file}}) do
        case FileUploader.store({file, "upload"}) do
          {:ok, _filename} ->
            conn
            |> put_flash(:info, "File uploaded successfully.")
            |> redirect(to: ~p"/uploads")

          {:error, reason} ->
            conn
            |> put_flash(:error, "Upload failed: \#{reason}")
            |> render(:new)
        end
      end

      def create(conn, _) do
        conn
        |> put_flash(:error, "No file selected.")
        |> render(:new)
      end
    end
    """)
  end

  defp create_upload_templates(project_path) do
    app_name = Path.basename(project_path)
    templates_dir = Path.join([project_path, "lib", "#{app_name}_web", "controllers", "upload_html"])
    File.mkdir_p!(templates_dir)

    create_file_from_template(templates_dir, "new.html.heex", """
    <h1>Upload File</h1>
    <form action={~p"/uploads"} method="post" enctype="multipart/form-data">
      <input type="file" name="upload[file]" />
      <button type="submit">Upload</button>
    </form>
    """)

    create_file_from_template(templates_dir, "index.html.heex", """
    <h1>Uploaded Files</h1>
    <%= for file <- @files do %>
      <p><%= file %></p>
    <% end %>
    """)
  end

  defp update_router(project_path) do
    app_name = Path.basename(project_path)
    router_file = Path.join([project_path, "lib", "#{app_name}_web", "router.ex"])
    content = File.read!(router_file)
    app_module = Macro.camelize(app_name)

    upload_routes = """
      resources "/uploads", #{app_module}Web.UploadController, only: [:index, :new, :create]
    """

    unless String.contains?(content, "resources \"/uploads\"") do
      updated_content = String.replace(content, "scope \"/\", #{app_module}Web do", "scope \"/\", #{app_module}Web do\n#{upload_routes}")
      File.write!(router_file, updated_content)
    end
  end

  defp create_waffle_documentation(project_path) do

    app_name = Path.basename(project_path)

    content = """
    # Waffle File Uploads Integration

    Catalyst integrated Waffle for file uploads.

    ## Added:
    - Waffle dependencies in `mix.exs`
    - File uploader at `lib/#{app_name}/uploaders/file_uploader.ex`
    - UploadController at `lib/#{app_name}_web/controllers/upload_controller.ex`
    - Upload templates at `lib/#{app_name}_web/controllers/upload_html/`
    - Routes for `/uploads`

    ## Usage:
    - Access upload form: `/uploads/new`
    - List files: `/uploads`
    """

    create_documentation(project_path, "waffle", content)
  end


end
