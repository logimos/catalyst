defmodule Catalyst.Modules.Auth do
  @moduledoc """
  Configures phx_gen_auth for user authentication in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    try do
      inject_dependency(project_path, {:phx_gen_auth, "~> 0.7", only: [:dev], runtime: false})
      run_auth_generator(project_path)
      create_auth_documentation(project_path)
      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp run_auth_generator(project_path) do

    # Get dependencies first
    {_, 0} = System.cmd("mix", ["deps.get"], cd: project_path)

    # Generate auth
    {_, 0} = System.cmd("mix", ["phx.gen.auth", "Accounts", "User", "users", "--binary-id"], cd: project_path)

    # Run migrations
    {_, 0} = System.cmd("mix", ["ecto.migrate"], cd: project_path)
  end

  defp create_auth_documentation(project_path) do
    content = """
# Authentication Setup

Catalyst has integrated phx_gen_auth into your Phoenix project for user authentication.

## What was added:
- phx_gen_auth dependency
- User accounts schema and context
- Authentication controllers and views
- Database migrations for users table
- Login/registration forms

## Usage

Users can now register and login through the generated authentication system.

### Routes added:
- `GET /users/register` - Registration form
- `POST /users/register` - Create new user
- `GET /users/log_in` - Login form
- `POST /users/log_in` - Authenticate user
- `DELETE /users/log_out` - Logout user

### Protecting routes:
```elixir
# In your router.ex
pipeline :require_authenticated_user do
  plug :ensure_authenticated_user
end

scope "/", YourAppWeb do
  pipe_through [:browser, :require_authenticated_user]
  # Protected routes here
end
```

### Current user in templates:
```elixir
<%= if @current_user do %>
  Welcome, <%= @current_user.email %>!
<% end %>
```
"""

    create_documentation(project_path, "auth", content)
  end
end
