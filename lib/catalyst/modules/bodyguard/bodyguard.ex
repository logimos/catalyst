defmodule Catalyst.Modules.Bodyguard do
  @moduledoc """
  Configures Bodyguard for authorization with authentication integration.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:bodyguard, "~> 2.4"})
    create_policies(project_path)
    create_authorization_helpers(project_path)
    create_bodyguard_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_policies(project_path) do
    app_name = Path.basename(project_path)
    policies_dir = Path.join([project_path, "lib", app_name, "policies"])
    File.mkdir_p!(policies_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(policies_dir, "general_policy.ex", """
    defmodule #{app_module}.Policies.GeneralPolicy do
      @behaviour Bodyguard.Policy

      def authorize(:index, _user, _params), do: :ok
      def authorize(:show, _user, _params), do: :ok
      def authorize(:create, user, _params), do: !!user
      def authorize(:update, user, %{id: id}), do: user && user.id == id
      def authorize(:delete, user, %{id: id}), do: user && user.id == id
      def authorize(_, _, _), do: false
    end
    """)

    create_file_from_template(policies_dir, "post_policy.ex", """
    defmodule #{app_module}.Policies.PostPolicy do
      @behaviour Bodyguard.Policy

      def authorize(:index, _user, _params), do: :ok
      def authorize(:show, _user, _params), do: :ok
      def authorize(:create, user, _params), do: !!user
      def authorize(:update, user, %{post: post}), do: user && user.id == post.user_id
      def authorize(:delete, user, %{post: post}), do: user && user.id == post.user_id
      def authorize(_, _, _), do: false
    end
    """)

    create_file_from_template(policies_dir, "user_policy.ex", """
    defmodule #{app_module}.Policies.UserPolicy do
      @behaviour Bodyguard.Policy

      def authorize(:index, user, _params), do: user && user.role == "admin"
      def authorize(:show, user, %{id: id}), do: user && (user.id == id || user.role == "admin")
      def authorize(:create, _user, _params), do: true
      def authorize(:update, user, %{id: id}), do: user && user.id == id
      def authorize(:delete, user, %{id: id}), do: user && user.role == "admin"
      def authorize(_, _, _), do: false
    end
    """)
  end

  defp create_authorization_helpers(project_path) do
    app_name = Path.basename(project_path)
    web_dir = Path.join([project_path, "lib", "#{app_name}_web"])
    plugs_dir = Path.join([web_dir, "plugs"])
    File.mkdir_p!(plugs_dir)

    app_web_module = Macro.camelize("#{app_name}_web")
    app_module = Macro.camelize(app_name)

    create_file_from_template(plugs_dir, "authorize.ex", """
    defmodule #{app_web_module}.Plugs.Authorize do
      import Plug.Conn
      import Phoenix.Controller

      def init(opts), do: opts

      def call(conn, opts) do
        user = conn.assigns.current_user
        policy = opts[:policy] || #{app_module}.Policies.GeneralPolicy
        action = opts[:action] || action_name(conn)
        params = opts[:params] || conn.params

        case Bodyguard.authorize(policy, action, user, params) do
          :ok -> conn
          {:error, _reason} ->
            conn
            |> put_status(:forbidden)
            |> put_view(#{app_web_module}.ErrorView)
            |> render("403.html")
            |> halt()
        end
      end
    end
    """)

    create_file_from_template(web_dir, "authorization.ex", """
    defmodule #{app_web_module}.Authorization do
      @moduledoc \"\"\"
      Authorization helpers for use in templates and controllers.
      \"\"\"

      alias #{app_module}.Policies.GeneralPolicy

      def can?(user, action, params \\\\ %{}) do
        Bodyguard.authorize(GeneralPolicy, action, user, params) == :ok
      end

      def can?(user, policy, action, params \\\\ %{}) do
        Bodyguard.authorize(policy, action, user, params) == :ok
      end

      def cannot?(user, action, params \\\\ %{}), do: not can?(user, action, params)
      def cannot?(user, policy, action, params \\\\ %{}), do: not can?(user, policy, action, params)
    end
    """)
  end

  defp create_bodyguard_documentation(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)
    app_web_module = Macro.camelize("#{app_name}_web")

    content = """
    # Bodyguard Authorization

    Catalyst has integrated Bodyguard into your Phoenix project.

    ## Changes Made:
    - Added Bodyguard dependency to `mix.exs`
    - Generated policies under `lib/#{app_name}/policies/`
    - Created authorization plug (`#{app_web_module}.Plugs.Authorize`)
    - Added authorization helpers (`#{app_web_module}.Authorization`)

    ## Example Usage:

    ### Controller Plug:
    ```elixir
    plug #{app_web_module}.Plugs.Authorize, policy: #{app_module}.Policies.PostPolicy
    ```

    ### Template Helpers:
    ```heex
    <%= if #{app_web_module}.Authorization.can?(@current_user, :create) do %>
      <%= link "New Post", to: Routes.post_path(@conn, :new) %>
    <% end %>
    ```
    """

    create_documentation(project_path, "bodyguard", content)
  end

end
