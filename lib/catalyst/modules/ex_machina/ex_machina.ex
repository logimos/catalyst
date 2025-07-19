defmodule Catalyst.Modules.ExMachina do
  @moduledoc """
  Configures ExMachina for test factories in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:ex_machina, "~> 2.7", only: :test})
    create_factories(project_path)
    create_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_factories(project_path) do
    app_name = Path.basename(project_path)
    test_dir = Path.join([project_path, "test"])
    factories_dir = Path.join(test_dir, "factories")
    File.mkdir_p!(factories_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(factories_dir, "factory.ex", """
defmodule #{app_module}.Factory do
  @moduledoc \"\"\"
  ExMachina factory for creating test data.
  \"\"\"

  use ExMachina.Ecto, repo: #{app_module}.Repo

  def user_factory do
    %#{app_module}.Accounts.User{
      email: sequence(:email, &"user\#{&1}@example.com"),
      username: sequence(:username, &"user\#{&1}"),
      password_hash: Bcrypt.hash_pwd_salt("password123"),
      confirmed_at: ~U[2024-01-01 00:00:00Z]
    }
  end

  def post_factory do
    %#{app_module}.Content.Post{
      title: sequence(:title, &"Post Title \#{&1}"),
      content: sequence(:content, &"This is the content for post \#{&1}"),
      published: true,
      author: build(:user)
    }
  end

  def comment_factory do
    %#{app_module}.Content.Comment{
      content: sequence(:content, &"Comment \#{&1}"),
      author: build(:user),
      post: build(:post)
    }
  end

  def category_factory do
    %#{app_module}.Content.Category{
      name: sequence(:name, &"Category \#{&1}"),
      description: sequence(:description, &"Description for category \#{&1}")
    }
  end

  def tag_factory do
    %#{app_module}.Content.Tag{
      name: sequence(:name, &"tag\#{&1}"),
      description: sequence(:description, &"Description for tag \#{&1}")
    }
  end

  # Custom factory functions
  def admin_user_factory do
    user_factory()
    |> with_admin_role()
  end

  def published_post_factory do
    post_factory()
    |> with_published_status()
  end

  def draft_post_factory do
    post_factory()
    |> with_draft_status()
  end

  # Factory helpers
  def with_admin_role(user) do
    %{user | role: "admin"}
  end

  def with_published_status(post) do
    %{post | published: true, published_at: ~U[2024-01-01 00:00:00Z]}
  end

  def with_draft_status(post) do
    %{post | published: false, published_at: nil}
  end

  def with_comments(post, count \\ 3) do
    %{post | comments: build_list(count, :comment, post: post)}
  end

  def with_tags(post, count \\ 2) do
    %{post | tags: build_list(count, :tag)}
  end
end
""")

    create_file_from_template(test_dir, "support/factory_helper.ex", """
defmodule #{app_module}.FactoryHelper do
  @moduledoc \"\"\"
  Helper functions for using factories in tests.
  \"\"\"

  import #{app_module}.Factory

  def create_user(attrs \\ %{}) do
    attrs
    |> user_factory()
    |> #{app_module}.Repo.insert!()
  end

  def create_post(attrs \\ %{}) do
    attrs
    |> post_factory()
    |> #{app_module}.Repo.insert!()
  end

  def create_comment(attrs \\ %{}) do
    attrs
    |> comment_factory()
    |> #{app_module}.Repo.insert!()
  end

  def create_category(attrs \\ %{}) do
    attrs
    |> category_factory()
    |> #{app_module}.Repo.insert!()
  end

  def create_tag(attrs \\ %{}) do
    attrs
    |> tag_factory()
    |> #{app_module}.Repo.insert!()
  end

  # Build without inserting
  def build_user(attrs \\ %{}) do
    attrs
    |> user_factory()
  end

  def build_post(attrs \\ %{}) do
    attrs
    |> post_factory()
  end

  def build_comment(attrs \\ %{}) do
    attrs
    |> comment_factory()
  end

  # List factories
  def create_users(count, attrs \\ %{}) do
    build_list(count, :user, attrs)
    |> Enum.map(&#{app_module}.Repo.insert!/1)
  end

  def create_posts(count, attrs \\ %{}) do
    build_list(count, :post, attrs)
    |> Enum.map(&#{app_module}.Repo.insert!/1)
  end

  def create_comments(count, attrs \\ %{}) do
    build_list(count, :comment, attrs)
    |> Enum.map(&#{app_module}.Repo.insert!/1)
  end
end
""")
  end

  defp create_documentation(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)

    markdown_content = """
# ExMachina Test Factories

Catalyst has integrated ExMachina for creating test factories in your Phoenix application.

## Changes Made:
- Added ExMachina dependency to `mix.exs` (test only)
- Created factory definitions in `test/factories/factory.ex`
- Generated factory helper module in `test/support/factory_helper.ex`

## Factory Definitions

Located in `test/factories/factory.ex`

Available factories:
- **user** - Basic user with email and password
- **post** - Blog post with title and content
- **comment** - Comment with content and associations
- **category** - Content category
- **tag** - Content tag

## Basic Usage

### Create a single record:
```elixir
import #{app_module}.Factory

# Create and insert a user
user = insert(:user)

# Create and insert a post
post = insert(:post)

# Create with custom attributes
user = insert(:user, email: "custom@example.com", username: "custom_user")
```

### Build without inserting:
```elixir
# Build user struct without saving
user = build(:user)

# Build with custom attributes
post = build(:post, title: "Custom Title", published: false)
```

### Create lists:
```elixir
# Create 5 users
users = insert_list(5, :user)

# Create 3 posts with custom attributes
posts = insert_list(3, :post, published: true)
```

## Factory Helpers

Located in `test/support/factory_helper.ex`

### Quick creation functions:
```elixir
alias #{app_module}.FactoryHelper

# Create records directly
user = FactoryHelper.create_user()
post = FactoryHelper.create_post()
comment = FactoryHelper.create_comment()

# Create with custom attributes
admin_user = FactoryHelper.create_user(%{role: "admin"})
published_post = FactoryHelper.create_post(%{published: true})
```

### Build functions:
```elixir
# Build without inserting
user = FactoryHelper.build_user()
post = FactoryHelper.build_post(%{title: "Test Post"})
```

### List creation:
```elixir
# Create multiple records
users = FactoryHelper.create_users(5)
posts = FactoryHelper.create_posts(3, %{published: true})
```

## Custom Factories

### Admin user:
```elixir
# Create admin user
admin = insert(:admin_user)

# Or with custom attributes
admin = insert(:admin_user, email: "admin@example.com")
```

### Published post:
```elixir
# Create published post
published_post = insert(:published_post)

# Create draft post
draft_post = insert(:draft_post)
```

### Post with associations:
```elixir
# Post with comments
post_with_comments = insert(:post) |> with_comments(5)

# Post with tags
post_with_tags = insert(:post) |> with_tags(3)

# Post with both comments and tags
rich_post = insert(:post) |> with_comments(3) |> with_tags(2)
```

## Testing Examples

### Controller tests:
```elixir
defmodule #{app_module}Web.PostControllerTest do
  use #{app_module}Web.ConnCase
  import #{app_module}.Factory

  test "GET /posts", %{conn: conn} do
    # Create test data
    user = insert(:user)
    posts = insert_list(3, :post, author: user)

    conn = get(conn, ~p"/posts")
    assert html_response(conn, 200) =~ "Posts"
  end

  test "POST /posts", %{conn: conn} do
    user = insert(:user)
    post_params = params_for(:post, author: user)

    conn = post(conn, ~p"/posts", post: post_params)
    assert redirected_to(conn) == ~p"/posts"
  end
end
```

### Context tests:
```elixir
defmodule #{app_module}.ContentTest do
  use #{app_module}.DataCase
  import #{app_module}.Factory

  test "create_post/1 with valid data" do
    user = insert(:user)
    post_attrs = params_for(:post, author: user)

    assert {:ok, post} = Content.create_post(post_attrs)
    assert post.title == post_attrs.title
    assert post.author_id == user.id
  end

  test "list_posts/0 returns all posts" do
    posts = insert_list(3, :post)
    assert Content.list_posts() == posts
  end
end
```

### Integration tests:
```elixir
defmodule #{app_module}.UserRegistrationTest do
  use #{app_module}.DataCase
  import #{app_module}.Factory

  test "user can register with valid data" do
    user_attrs = params_for(:user, password: "password123")

    assert {:ok, user} = Accounts.register_user(user_attrs)
    assert user.email == user_attrs.email
    assert user.username == user_attrs.username
  end
end
```

## Advanced Factory Patterns

### Sequences:
```elixir
# Factory automatically uses sequences
user1 = insert(:user)  # email: "user1@example.com"
user2 = insert(:user)  # email: "user2@example.com"
user3 = insert(:user)  # email: "user3@example.com"
```

### Associations:
```elixir
# Create post with author
post = insert(:post, author: insert(:user))

# Create comment with post and author
comment = insert(:comment, post: post, author: insert(:user))
```

### Traits:
```elixir
# Use custom factory functions
admin = insert(:admin_user)
published_post = insert(:published_post)
draft_post = insert(:draft_post)
```

### Build strategies:
```elixir
# Build without associations
post = build(:post)

# Build with associations
post_with_author = build(:post, author: build(:user))

# Build with nested associations
post_with_comments = build(:post, comments: build_list(3, :comment))
```

## Best Practices

### 1. Factory Organization
- Keep factories simple and focused
- Use descriptive factory names
- Group related factories together
- Use traits for variations

### 2. Data Consistency
- Use sequences for unique fields
- Provide realistic default values
- Ensure associations are valid
- Test factory behavior

### 3. Performance
- Use `build` for unit tests
- Use `insert` sparingly in integration tests
- Avoid creating unnecessary associations
- Clean up test data properly

### 4. Maintainability
- Keep factories up to date with schema changes
- Use helper functions for complex setups
- Document custom factory functions
- Use meaningful attribute names

## Factory Tips

### Custom sequences:
```elixir
def unique_username_factory do
  %#{app_module}.Accounts.User{
    username: sequence(:username, &"user\#{&1}_\#{System.unique_integer()}"),
    email: sequence(:email, &"user\#{&1}@example.com")
  }
end
```

### Conditional attributes:
```elixir
def post_factory do
  %#{app_module}.Content.Post{
    title: sequence(:title, &"Post \#{&1}"),
    content: sequence(:content, &"Content \#{&1}"),
    published: true,
    published_at: ~U[2024-01-01 00:00:00Z]
  }
end

def draft_post_factory do
  post_factory()
  |> with_draft_status()
end
```

### Complex associations:
```elixir
def post_with_comments_factory do
  post = post_factory()
  comments = build_list(3, :comment, post: post)
  %{post | comments: comments}
end
```

### Testing edge cases:
```elixir
# Test with minimal data
minimal_user = build(:user, email: nil, username: nil)

# Test with maximum data
complete_user = build(:user,
  email: "complete@example.com",
  username: "complete_user",
  bio: "A complete user profile",
  avatar_url: "https://example.com/avatar.jpg"
)
```
"""

    create_documentation(project_path, "ex_machina", markdown_content)
  end
end
