# Catalyst - Modular Phoenix Project Generator

🚀 **Catalyst** is an interactive, modular Phoenix project generator that sets up a complete development environment with everything you need for modern web development.

## Features

### Core Phoenix Setup
- ✅ Interactive project creation
- ✅ Database selection (Postgres, MySQL, SQLite)
- ✅ Tailwind CSS integration (built-in with Phoenix)
- ✅ Modern development environment

### Optional Modules
- 🔧 **Oban** - Background job processing with database schema and sample workers
- 🔐 **Authentication** - User registration and login with phx_gen_auth
- ⚡ **LiveView** - Real-time interactive examples and components
- 🛡️ **Bodyguard** - Authorization policies integrated with authentication
- 🎯 **Absinthe** - GraphQL API with schema and resolvers
- 📁 **Waffle** - File uploads with uploader and controller
- 🌐 **HTTPoison** - HTTP client for external API requests
- 📧 **Swoosh** - Email functionality with mailer and templates
- 🧪 **ExMachina** - Test factories for reliable test data
- ✅ **Credo** - Code quality analysis and linting
- 🔍 **Dialyxir** - Static analysis and type checking
- ⚡ **Alpine.js** - Lightweight JavaScript framework for interactivity
- 🐳 **Docker** - Containerized development and deployment

## Installation

```bash
# Clone the repository
git clone https://github.com/your-username/catalyst.git
cd catalyst

# Install dependencies
mix deps.get

# Build the project
mix compile
```

## Usage

### Create a New Phoenix Project

```bash
# Run the interactive setup
mix catalyst.new
```

The setup will guide you through:

1. **Project Configuration**
   - Project name (with validation)
   - Database choice (Postgres/MySQL/SQLite)

2. **Module Selection**
   - Choose which modules to include
   - Each module adds specific functionality

3. **Automatic Setup**
   - Creates Phoenix project with your choices
   - Installs and configures selected modules
   - Generates comprehensive documentation

### Example Workflow

```bash
$ mix catalyst.new
🚀 Welcome to Catalyst - Modular Phoenix Setup!
Project name? my_awesome_app
Database [1] Postgres (default), [2] MySQL, [3] SQLite: 1
Include Oban (background jobs)? [Yn] y
Include Authentication (phx_gen_auth)? [Yn] y
Include LiveView with examples? [Yn] y
Include Bodyguard (authorization)? [Yn] y
Include Absinthe (GraphQL)? [Yn] y
Include Waffle (file uploads)? [Yn] y
Include HTTPoison (HTTP requests)? [Yn] y
Include Swoosh (email)? [Yn] y
Include ExMachina (test factories)? [Yn] y
Include Credo (code quality)? [Yn] y
Include Dialyxir (static analysis)? [Yn] y
Include Alpine.js? [Yn] y
Include Docker support? [Yn] n

✅ Phoenix project created successfully!
✅ Oban setup completed!
✅ Auth setup completed!
✅ LiveView setup completed!
✅ Bodyguard setup completed!
✅ Absinthe setup completed!
✅ Waffle setup completed!
✅ HTTPoison setup completed!
✅ Swoosh setup completed!
✅ ExMachina setup completed!
✅ Credo setup completed!
✅ Dialyxir setup completed!
✅ Alpine setup completed!

🎉 Catalyst setup is complete! Navigate to your project with:
  cd my_awesome_app
  mix setup
```

## Module Documentation

Each module includes comprehensive documentation in `docs/catalyst/`:

- 📖 **Oban** - Background job processing guide
- 🔐 **Authentication** - User auth setup and usage
- ⚡ **LiveView** - Real-time interactive components
- 🛡️ **Bodyguard** - Authorization policies and helpers
- 🎯 **Absinthe** - GraphQL API development
- 📁 **Waffle** - File upload handling
- 🌐 **HTTPoison** - HTTP client usage
- 📧 **Swoosh** - Email functionality
- 🧪 **ExMachina** - Test factory patterns
- ✅ **Credo** - Code quality guidelines
- 🔍 **Dialyxir** - Static analysis setup
- ⚡ **Alpine.js** - Interactive components and directives
- 🐳 **Docker** - Containerization and deployment

## Module Details

### Oban (Background Jobs)
- Reliable background job processing with database schema
- Sample EmailWorker, ExampleWorker, and NotificationWorker templates
- Multiple queue configuration (default, emails, critical)
- Job scheduling and monitoring capabilities
- Automatic retry and error handling

### Authentication
- User registration and login with phx_gen_auth
- Password reset functionality
- Session management
- Route protection helpers

### LiveView
- Real-time interactive components
- Multiple example implementations
- Event handling and state management
- Smooth transitions and animations

### Bodyguard
- Authorization policies and helpers
- Integration with authentication
- Policy-based access control
- Plugs and helpers for controllers

### Absinthe (GraphQL)
- Complete GraphQL API setup
- Schema definitions and resolvers
- Query and mutation examples
- Router integration

### Waffle (File Uploads)
- File upload handling with uploader
- Controller and template integration
- Route configuration
- Upload validation and processing

### HTTPoison (HTTP Requests)
- HTTP client for external API calls
- GET, POST, PUT, DELETE, PATCH methods
- JSON encoding/decoding
- Error handling and response processing

### Swoosh (Email)
- Email functionality with mailer
- Welcome, password reset, and notification emails
- HTML and text email templates
- Background job integration

### ExMachina (Test Factories)
- Test factories for reliable test data
- User, post, comment, category, and tag factories
- Factory helpers and custom traits
- Build and insert functions

### Credo (Code Quality)
- Comprehensive code quality analysis
- Consistency, design, and readability checks
- Refactoring opportunities
- Warning detection

### Dialyxir (Static Analysis)
- Static type analysis and checking
- Dead code detection
- Race condition detection
- Specification checking

### Alpine.js
- Lightweight JavaScript framework
- Reactive components
- Event handling
- Smooth transitions

### Docker
- Multi-stage production builds
- Development environment with database
- Containerized deployment
- Environment configuration

## Development

### Project Structure

```
lib/
├── catalyst/
│   ├── modules/
│   │   ├── oban/
│   │   ├── auth/
│   │   ├── liveview/
│   │   ├── bodyguard/
│   │   ├── absinthe/
│   │   ├── waffle/
│   │   ├── httpoison/
│   │   ├── swoosh/
│   │   ├── ex_machina/
│   │   ├── credo/
│   │   ├── dialyxir/
│   │   ├── alpine/
│   │   └── docker/
│   └── utils.ex
├── mix/
│   └── tasks/
│       └── catalyst.new.ex
└── catalyst.ex
```

### Adding New Modules

1. Create a new module directory in `lib/catalyst/modules/`
2. Implement the `setup/1` function using the Utils module
3. Add comprehensive documentation
4. Update the module list in `catalyst.new.ex`

### Module Template

```elixir
defmodule Catalyst.Modules.YourModule do
  @moduledoc """
  Description of what this module does.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:your_dep, "~> 1.0"})
    create_your_files(project_path)
    create_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end
end
```

## Best Practices

### Module Development
- Use the Utils module for consistency
- Provide comprehensive documentation
- Include real-world examples
- Handle errors gracefully
- Test all functionality

### Code Quality
- Run Credo for code quality checks
- Use Dialyxir for static analysis
- Follow Elixir best practices
- Write comprehensive tests

### Testing
- Use ExMachina factories for test data
- Write integration tests
- Test error scenarios
- Maintain test coverage

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your module or improvement
4. Add tests and documentation
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Phoenix Framework team for the excellent web framework
- Oban team for reliable background job processing
- Alpine.js team for lightweight JavaScript framework
- All the Elixir community for amazing tools and libraries

---

**Catalyst** - Building better Phoenix applications, one module at a time. 🚀

