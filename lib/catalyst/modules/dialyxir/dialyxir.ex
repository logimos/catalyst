defmodule Catalyst.Modules.Dialyxir do
  @moduledoc """
  Configures Dialyxir for static analysis in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false})
    create_dialyzer_config(project_path)
    create_dialyzer_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_dialyzer_config(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)

    create_file_from_template(project_path, ".dialyzer.exs", """
defmodule #{app_module}.Dialyzer do
  @moduledoc \"\"\"
  Dialyzer configuration for #{app_module}.
  \"\"\"

  def project do
    [
      app: :#{app_name},
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  defp deps do
    [
      # Your dependencies here
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true,
      no_check_plt: false,
      plt_check: true,
      remove_defaults: [:unknown],
      warnings: [
        :unmatched_returns,
        :error_handling,
        :race_conditions,
        :underspecs,
        :unknown,
        :unreachable
      ]
    ]
  end
end
""")

    create_file_from_template(project_path, ".dialyzer_ignore.exs", """
# Dialyzer ignore file for #{app_module}
# Add patterns to ignore specific warnings

[
  # Ignore warnings for generated files
  {~r"lib/#{app_name}/generated/", :unknown},

  # Ignore warnings for test files
  {~r"test/", :unknown},

  # Ignore warnings for specific modules
  # {~r"lib/#{app_name}/web/controllers/.*_controller.ex", :unknown},

  # Ignore specific warning types
  # {:unknown, {SomeModule, :some_function, 1}},

  # Ignore warnings for external dependencies
  # {~r"deps/", :unknown}
]
""")
  end

  defp create_dialyzer_documentation(project_path) do
    app_name = Path.basename(project_path)

    markdown_content = """
# Dialyxir Static Analysis

Catalyst has integrated Dialyxir for static analysis in your Phoenix application.

## Changes Made:
- Added Dialyxir dependency to `mix.exs` (dev and test environments)
- Created `.dialyzer.exs` configuration file
- Created `.dialyzer_ignore.exs` for ignoring specific warnings
- Configured comprehensive static analysis

## Dialyzer Configuration

Located in `.dialyzer.exs`

Features:
- **Type checking** - Static type analysis
- **Dead code detection** - Unreachable code identification
- **Race condition detection** - Concurrency issues
- **Error handling analysis** - Exception handling patterns
- **Specification checking** - @spec compliance

## Basic Usage

### Run static analysis:
```bash
mix dialyzer
```

### Build PLT (Persistent Lookup Table):
```bash
mix dialyzer --plt
```

### Check specific modules:
```bash
mix dialyzer lib/my_module.ex
```

### Generate warnings report:
```bash
mix dialyzer --format dialyzer
```

## Common Issues and Fixes

### 1. Missing @spec Annotations
```elixir
# ❌ No specification
def process_user(user) do
  # ...
end

# ✅ With specification
@spec process_user(User.t()) :: {:ok, User.t()} | {:error, String.t()}
def process_user(user) do
  # ...
end
```

### 2. Unmatched Returns
```elixir
# ❌ Inconsistent return types
def get_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, "User not found"}
    user -> user  # Should return {:ok, user}
  end
end

# ✅ Consistent return types
def get_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, "User not found"}
    user -> {:ok, user}
  end
end
```

### 3. Undefined Functions
```elixir
# ❌ Undefined function
def process_data(data) do
  undefined_function(data)  # This function doesn't exist
end

# ✅ Define the function or use existing one
def process_data(data) do
  process_data_safely(data)
end

defp process_data_safely(data) do
  # Implementation
end
```

### 4. Type Mismatches
```elixir
# ❌ Type mismatch
def add_numbers(a, b) when is_integer(a) and is_integer(b) do
  a + b
end

def add_numbers(a, b) do
  add_numbers(String.to_integer(a), String.to_integer(b))
end

# ✅ Better type handling
def add_numbers(a, b) when is_integer(a) and is_integer(b) do
  {:ok, a + b}
end

def add_numbers(a, b) when is_binary(a) and is_binary(b) do
  case {Integer.parse(a), Integer.parse(b)} do
    {{a_int, _}, {b_int, _}} -> {:ok, a_int + b_int}
    _ -> {:error, "Invalid number format"}
  end
end

def add_numbers(_, _) do
  {:error, "Invalid arguments"}
end
```

## Configuration Options

### Warning Levels:
```elixir
# In .dialyzer.exs
warnings: [
  :unmatched_returns,    # Functions with inconsistent return types
  :error_handling,       # Missing error handling
  :race_conditions,      # Potential race conditions
  :underspecs,           # Missing @spec annotations
  :unknown,              # Unknown functions
  :unreachable           # Unreachable code
]
```

### PLT Configuration:
```elixir
# In .dialyzer.exs
plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
plt_add_apps: [:ex_unit, :phoenix],
no_check_plt: false,
plt_check: true
```

### Ignore Patterns:
```elixir
# In .dialyzer_ignore.exs
[
  # Ignore generated files
  {~r"lib/#{app_name}/generated/", :unknown},

  # Ignore specific warnings
  {:unknown, {SomeModule, :some_function, 1}},

  # Ignore test files
  {~r"test/", :unknown}
]
```

## Integration with CI/CD

### GitHub Actions:
```yaml
name: Dialyzer
on: [push, pull_request]
jobs:
  dialyzer:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: erlef/setup-beam@v1
        with:
          otp-version: '25.0'
          elixir-version: '1.14.0'
      - run: mix deps.get
      - run: mix dialyzer --plt
      - run: mix dialyzer
```

### GitLab CI:
```yaml
dialyzer:
  stage: test
  script:
    - mix deps.get
    - mix dialyzer --plt
    - mix dialyzer
  only:
    - merge_requests
    - master
```

## Best Practices

### 1. Type Specifications
- Add @spec annotations to public functions
- Use proper types from your schemas
- Document complex return types
- Use @type for custom types

### 2. Error Handling
- Handle all possible error cases
- Use consistent error return types
- Document error conditions
- Test error scenarios

### 3. Function Design
- Keep functions focused and small
- Use pattern matching effectively
- Avoid complex conditional logic
- Prefer explicit over implicit

### 4. Code Organization
- Group related functions together
- Use consistent naming conventions
- Separate concerns clearly
- Document complex logic

## Advanced Usage

### Custom Types:
```elixir
# Define custom types
@type user_id :: non_neg_integer()
@type user_email :: String.t()
@type user_role :: :admin | :user | :guest

@type user :: %{
  id: user_id(),
  email: user_email(),
  role: user_role(),
  created_at: DateTime.t()
}

# Use in specifications
@spec create_user(user_email(), user_role()) :: {:ok, user()} | {:error, String.t()}
def create_user(email, role) do
  # Implementation
end
```

### Complex Specifications:
```elixir
# Handle multiple return types
@spec process_data(term()) ::
  {:ok, map()} |
  {:error, :invalid_data} |
  {:error, :processing_failed}

def process_data(data) do
  case validate_data(data) do
    {:ok, valid_data} -> process_valid_data(valid_data)
    {:error, reason} -> {:error, reason}
  end
end
```

### Ignoring Specific Warnings:
```elixir
# In .dialyzer_ignore.exs
[
  # Ignore specific function warnings
  {:unknown, {MyApp.SomeModule, :some_function, 1}},

  # Ignore specific file patterns
  {~r"lib/my_app/generated/", :unknown},

  # Ignore specific warning types
  {~r"lib/", :underspecs}
]
```

## Common Warning Types

### :unmatched_returns
- Functions returning different types in different code paths
- Fix by ensuring consistent return types

### :error_handling
- Missing error handling in functions
- Add proper error handling and return types

### :race_conditions
- Potential race conditions in concurrent code
- Review and fix concurrency issues

### :underspecs
- Missing @spec annotations
- Add type specifications to functions

### :unknown
- Unknown function calls
- Define missing functions or fix imports

### :unreachable
- Unreachable code paths
- Remove dead code or fix logic

## Performance Tips

### 1. PLT Management
- Build PLT once and reuse
- Update PLT when dependencies change
- Use plt_check: true for validation

### 2. Incremental Analysis
- Run Dialyzer on changed files only
- Use --no-check for faster runs
- Cache results when possible

### 3. Configuration
- Exclude test files from analysis
- Ignore generated code
- Use appropriate warning levels
"""

    create_documentation(project_path, "dialyxir", markdown_content)
  end
end
