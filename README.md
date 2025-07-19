# Catalyst - Modular Phoenix Project Generator

🚀 **Catalyst** is an interactive, modular Phoenix project generator that sets up a complete development environment with everything you need for modern web development.

## Features

### Core Phoenix Setup
- ✅ Interactive project creation
- ✅ Database selection (Postgres, MySQL, SQLite)
- ✅ Tailwind CSS integration
- ✅ Modern development environment

### Optional Modules
- 🔧 **Oban** - Background job processing with database schema and sample workers
- 🔐 **Authentication** - User registration and login with phx_gen_auth
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
Include Tailwind CSS? [Yn] y
Include Alpine.js? [Yn] y
Include Docker support? [Yn] n

✅ Phoenix project created successfully!
✅ Oban setup completed!
✅ Auth setup completed!
✅ Tailwind setup completed!
✅ Alpine setup completed!

🎉 Catalyst setup is complete! Navigate to your project with:
  cd my_awesome_app
  mix setup
```

## Module Documentation

Each module includes comprehensive documentation in `docs/catalyst/`:

- 📖 **Oban** - Background job processing guide
- 🔐 **Authentication** - User auth setup and usage
- 🎨 **Tailwind** - Custom components and styling
- ⚡ **Alpine.js** - Interactive components and directives
- 🐳 **Docker** - Containerization and deployment

## Module Details

### Oban (Background Jobs)
- Reliable background job processing with database schema
- Sample EmailWorker and ExampleWorker templates
- Multiple queue configuration (default, emails, critical)
- Job scheduling and monitoring capabilities
- Automatic retry and error handling

### Authentication
- User registration and login
- Password reset functionality
- Session management
- Route protection helpers

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
│   └── modules/
│       ├── oban/
│       ├── auth/
│       ├── alpine/
│       └── docker/
├── mix/
│   └── tasks/
│       └── catalyst.new.ex
└── catalyst.ex
```

### Adding New Modules

1. Create a new module directory in `lib/catalyst/modules/`
2. Implement the `setup/1` function
3. Add documentation
4. Update the module list in `catalyst.new.ex`

### Module Template

```elixir
defmodule Catalyst.Modules.YourModule do
  @moduledoc """
  Description of what this module does.
  """

  def setup(project_path) do
    try do
      # Your setup logic here
      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end
end
```

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
- Tailwind CSS team for utility-first CSS framework

---

**Catalyst** - Building better Phoenix applications, one module at a time. 🚀

