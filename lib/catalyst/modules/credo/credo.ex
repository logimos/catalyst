defmodule Catalyst.Modules.Credo do
  @moduledoc """
  Configures Credo for code quality analysis in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:credo, "~> 1.7", only: [:dev, :test], runtime: false})
    create_credo_config(project_path)
    create_credo_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_credo_config(project_path) do
    create_file_from_template(project_path, ".credo.exs", """
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "lib/",
          "src/",
          "test/",
          "web/",
          "apps/*/lib/",
          "apps/*/src/",
          "apps/*/test/",
          "apps/*/web/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      checks: [
        # Consistency Checks
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings},
        {Credo.Check.Consistency.ParameterPatternMatching},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses},
        {Credo.Check.Consistency.TabsOrSpaces},

        # Design Checks
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.DuplicatedCode, mass_threshold: 16, nodes_threshold: 2},
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Design.TagTODO, false},

        # Readability Checks
        {Credo.Check.Readability.AliasAs},
        {Credo.Check.Readability.BlockPipe},
        {Credo.Check.Readability.CharacterLiteral},
        {Credo.Check.Readability.ImplTrue},
        {Credo.Check.Readability.LargeNumbers},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.MultiAlias},
        {Credo.Check.Readability.NestedFunctionCalls},
        {Credo.Check.Readability.OneArityFunctionInPipe},
        {Credo.Check.Readability.ParenthesesInCondition},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.PreferImplicitTry},
        {Credo.Check.Readability.PreferUnquotedAtoms},
        {Credo.Check.Readability.QuotedFunctionNames},
        {Credo.Check.Readability.RedundantBlankLines},
        {Credo.Check.Readability.RedundantDef, false},
        {Credo.Check.Readability.RedundantDocAliases},
        {Credo.Check.Readability.RedundantFunctionClauses},
        {Credo.Check.Readability.RedundantModuleDoc},
        {Credo.Check.Readability.RedundantPatternMatch},
        {Credo.Check.Readability.RedundantPipe},
        {Credo.Check.Readability.Semicolons},
        {Credo.Check.Readability.SeparateAliasAndDef},
        {Credo.Check.Readability.SingleFunctionToBlockPipe},
        {Credo.Check.Readability.SpaceAfterCommas},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.UnnecessaryAliasExpansion},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.WithSingleClause},

        # Refactoring Opportunities
        {Credo.Check.Refactor.ABCSize, max_size: 60},
        {Credo.Check.Refactor.AppendSingleItem},
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.CyclomaticComplexity},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.EndExpressions},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.ModuleDependencies, false},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting},
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Refactor.UnlessWithElse},
        {Credo.Check.Refactor.WithClauses},

        # Warnings
        {Credo.Check.Warning.ApplicationConfigInModuleAttribute},
        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.ExpensiveEmptyEnumCheck},
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Warning.LeakyEnvironment},
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Warning.MixEnv},
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.OperationWithConstantResult},
        {Credo.Check.Warning.RaiseInsideRescue},
        {Credo.Check.Warning.SpecWithStruct},
        {Credo.Check.Warning.UnsafeExec},
        {Credo.Check.Warning.UnsafeToAtom},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedFileOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedPathOperation},
        {Credo.Check.Warning.UnusedRegexOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.UselessIf},
        {Credo.Check.Warning.UselessSymbol},
        {Credo.Check.Warning.WrongTestFileExtension},
        {Credo.Check.Warning.YodaConditions}
      ],
      color: true,
      checks_with_shared_config: [
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120}
      ]
    }
  ],
  color: true,
  explain: true,
  strict: true,
  parse_timeout: 5000,
  files: %{
    included: [
      "lib/",
      "src/",
      "test/",
      "web/",
      "apps/*/lib/",
      "apps/*/src/",
      "apps/*/test/",
      "apps/*/web/"
    ],
    excluded: [
      ~r"/_build/",
      ~r"/deps/",
      ~r"/node_modules/"
    ]
  }
}
""")
  end

  defp create_credo_documentation(project_path) do
    app_name = Path.basename(project_path)

    markdown_content = """
# Credo Code Quality

Catalyst has integrated Credo for code quality analysis in your Phoenix application.

## Changes Made:
- Added Credo dependency to `mix.exs` (dev and test environments)
- Created `.credo.exs` configuration file
- Configured comprehensive code quality checks

## Credo Configuration

Located in `.credo.exs`

Features:
- **Consistency checks** - Code style consistency
- **Design checks** - Code design and structure
- **Readability checks** - Code readability and formatting
- **Refactoring checks** - Code improvement opportunities
- **Warning checks** - Potential issues and anti-patterns

## Basic Usage

### Run all checks:
```bash
mix credo
```

### Run with explanations:
```bash
mix credo --strict
```

### Run specific checks:
```bash
mix credo --only readability
mix credo --only refactor
mix credo --only warning
```

### Exclude specific checks:
```bash
mix credo --ignore readability,refactor
```

### Generate HTML report:
```bash
mix credo --format html --output-file credo-report.html
```

## Common Issues and Fixes

### 1. Line Length
```elixir
# ❌ Too long
def create_user_with_very_long_parameter_list(email, username, password, first_name, last_name, bio, avatar_url, preferences, settings, metadata) do
  # ...
end

# ✅ Better
def create_user(attrs) do
  # ...
end
```

### 2. Function Complexity
```elixir
# ❌ Too complex
def process_user_data(user) do
  if user.active do
    if user.verified do
      if user.subscription_valid do
        # ... many nested conditions
      end
    end
  end
end

# ✅ Better
def process_user_data(user) do
  with true <- user.active,
       true <- user.verified,
       true <- user.subscription_valid do
    # ... process user
  end
end
```

### 3. Duplicated Code
```elixir
# ❌ Duplicated logic
def validate_email(email) do
  String.contains?(email, "@") and String.contains?(email, ".")
end

def validate_username(username) do
  String.length(username) > 3 and String.length(username) < 20
end

# ✅ Better - extract common validation
def validate_field(value, :email) do
  String.contains?(value, "@") and String.contains?(value, ".")
end

def validate_field(value, :username) do
  String.length(value) > 3 and String.length(value) < 20
end
```

### 4. Unused Variables
```elixir
# ❌ Unused variable
def process_data(data, _unused_param) do
  data
end

# ✅ Better
def process_data(data, _unused_param) do
  data
end
```

## Configuration Options

### Customize line length:
```elixir
# In .credo.exs
{Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 100}
```

### Disable specific checks:
```elixir
# In .credo.exs
{Credo.Check.Readability.ModuleDoc, false},
{Credo.Check.Design.AliasUsage, false}
```

### Custom file patterns:
```elixir
# In .credo.exs
files: %{
  included: [
    "lib/",
    "test/",
    "web/"
  ],
  excluded: [
    ~r"/_build/",
    ~r"/deps/",
    ~r"/node_modules/"
  ]
}
```

## Integration with CI/CD

### GitHub Actions:
```yaml
name: Credo
on: [push, pull_request]
jobs:
  credo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: erlef/setup-beam@v1
        with:
          otp-version: '25.0'
          elixir-version: '1.14.0'
      - run: mix deps.get
      - run: mix credo --strict
```

### GitLab CI:
```yaml
credo:
  stage: test
  script:
    - mix deps.get
    - mix credo --strict
  only:
    - merge_requests
    - master
```

## Best Practices

### 1. Regular Checks
- Run Credo before committing code
- Integrate with your CI/CD pipeline
- Review and fix issues regularly
- Use Credo as a learning tool

### 2. Configuration
- Customize rules for your team's style
- Disable rules that don't fit your project
- Add project-specific exclusions
- Document custom configurations

### 3. Team Workflow
- Agree on code quality standards
- Use Credo in code reviews
- Fix issues before merging
- Train team on Credo rules

### 4. Gradual Improvement
- Start with strict mode disabled
- Gradually enable stricter rules
- Focus on high-priority issues first
- Celebrate code quality improvements

## Advanced Usage

### Custom Checks:
```elixir
# Create custom check
defmodule MyApp.Credo.Check.CustomCheck do
  use Credo.Check, category: :warning, base: :module

  def run(source_file, params) do
    # Your custom check logic
  end
end
```

### Ignore Specific Lines:
```elixir
# Ignore specific line
def long_function_name(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10) do # credo:disable-line
  # ...
end
```

### Ignore Specific Functions:
```elixir
# Ignore entire function
def long_function_name(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10) do
  # credo:disable-line
  # ...
end
```

### Ignore Specific Modules:
```elixir
# In .credo.exs
excluded: [
  ~r"/_build/",
  ~r"/deps/",
  ~r"/node_modules/",
  ~r"lib/#{app_name}/generated/"
]
```

## Common Check Categories

### Consistency:
- Exception names
- Line endings
- Parameter pattern matching
- Space around operators
- Tabs or spaces

### Design:
- Alias usage
- Duplicated code
- TODO/FIXME tags

### Readability:
- Module documentation
- Function names
- Variable names
- Code formatting
- Line length

### Refactoring:
- Function complexity
- Nesting depth
- Code duplication
- Unused code

### Warnings:
- Unused variables
- Unused functions
- Unsafe operations
- Performance issues
"""

    create_documentation(project_path, "credo", markdown_content)
  end
end
