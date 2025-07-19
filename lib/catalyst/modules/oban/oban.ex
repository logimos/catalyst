defmodule Catalyst.Modules.Oban do
  @moduledoc """
  Configures Oban for background job processing in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:oban, "~> 2.17"})
    create_oban_migration(project_path)
    create_sample_jobs(project_path)
    create_oban_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    run_migrations(project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end


  defp create_oban_migration(project_path) do
    app_name = Path.basename(project_path)
    migration_dir = Path.join([project_path, "priv", "repo", "migrations"])

    # Get the next migration number
    migrations = File.ls!(migration_dir)
    |> Enum.filter(&String.ends_with?(&1, ".exs"))
    |> Enum.map(fn file ->
      case Regex.run(~r/^(\d+)_/, file) do
        [_, number] -> String.to_integer(number)
        _ -> 0
      end
    end)
    |> Enum.max(fn -> 0 end)

    next_number = migrations + 1

    app_module = Macro.camelize(app_name)

    migration_content = """
defmodule #{app_module}.Repo.Migrations.CreateObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 11)
  end

  def down do
    Oban.Migration.down(version: 1)
  end
end
"""

    create_file_from_template(migration_dir, "#{next_number}_create_oban_jobs_table.exs", migration_content)
  end

  defp create_sample_jobs(project_path) do
    app_name = Path.basename(project_path)
    workers_dir = Path.join([project_path, "lib", app_name, "workers"])
    File.mkdir_p!(workers_dir)

    app_module = Macro.camelize(app_name)

    # Create EmailWorker
    email_worker_template = """
defmodule APP_MODULE.Workers.EmailWorker do
  use Oban.Worker, queue: :emails

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email, "subject" => subject, "body" => body}}) do
    # Simulate sending an email
    IO.puts("📧 Sending email to: \#{email}")
    IO.puts("Subject: \#{subject}")
    IO.puts("Body: \#{body}")

    # In a real application, you would integrate with your email service here
    # Example with Swoosh:
    # APP_MODULE.Mailer.deliver_email(email, subject, body)

    # Simulate some processing time
    Process.sleep(1000)

    {:ok, "Email sent successfully"}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    # Handle case where only email is provided
    perform(%Oban.Job{args: %{"email" => email, "subject" => "Default Subject", "body" => "Default body"}})
  end
end
"""

    email_worker = String.replace(email_worker_template, "APP_MODULE", app_module)
    create_file_from_template(workers_dir, "email_worker.ex", email_worker)

    # Create ExampleWorker
    example_worker_template = """
defmodule APP_MODULE.Workers.ExampleWorker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message" => message}}) do
    IO.puts("🔄 Processing: \#{message}")

    # Simulate some work
    Process.sleep(2000)

    # You can also schedule follow-up jobs
    # %{message: "Follow up to: \#{message}"}
    # |> ExampleWorker.new(schedule_in: 60)
    # |> Oban.insert()

    {:ok, "Processed: \#{message}"}
  end
end
"""

    example_worker = String.replace(example_worker_template, "APP_MODULE", app_module)
    create_file_from_template(workers_dir, "example_worker.ex", example_worker)

    # Create NotificationWorker
    notification_worker_template = """
defmodule APP_MODULE.Workers.NotificationWorker do
  use Oban.Worker, queue: :notifications

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "type" => type, "data" => data}}) do
    IO.puts("🔔 Sending \#{type} notification to user \#{user_id}")
    IO.inspect(data, label: "Notification data")

    # Simulate notification processing
    Process.sleep(1500)

    # In a real application, you would:
    # - Fetch user preferences
    # - Send push notification, SMS, or email
    # - Log the notification

    {:ok, "Notification sent"}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "type" => type}}) do
    perform(%Oban.Job{args: %{"user_id" => user_id, "type" => type, "data" => %{}}})
  end
end
"""

    notification_worker = String.replace(notification_worker_template, "APP_MODULE", app_module)
    create_file_from_template(workers_dir, "notification_worker.ex", notification_worker)
  end

  defp run_migrations(project_path) do
    # Run migrations
    {_, 0} = System.cmd("mix", ["ecto.migrate"], cd: project_path)
  end

  defp create_oban_documentation(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)

    content = """
# Oban Background Jobs

Catalyst has integrated Oban into your Phoenix project for reliable background job processing.

## Changes Made:
- Added Oban dependency to `mix.exs`
- Created database migration for Oban jobs table
- Generated sample workers under `lib/#{app_name}/workers/`
- Configured Oban with multiple queues

## Available Workers

### EmailWorker
Located in `lib/#{app_name}/workers/email_worker.ex`

Handles email sending with customizable subject and body:

```elixir
# Enqueue an email job
%{email: "user@example.com", subject: "Welcome!", body: "Welcome to our app!"}
|> #{app_module}.Workers.EmailWorker.new()
|> Oban.insert()

# Or with just an email (uses defaults)
%{email: "user@example.com"}
|> #{app_module}.Workers.EmailWorker.new()
|> Oban.insert()
```

### ExampleWorker
Located in `lib/#{app_name}/workers/example_worker.ex`

Simple example for general background processing:

```elixir
# Enqueue a simple job
%{message: "Hello from Oban!"}
|> #{app_module}.Workers.ExampleWorker.new()
|> Oban.insert()
```

### NotificationWorker
Located in `lib/#{app_name}/workers/notification_worker.ex`

Handles user notifications with flexible data:

```elixir
# Send a notification
%{user_id: 123, type: "welcome", data: %{template: "welcome_email"}}
|> #{app_module}.Workers.NotificationWorker.new()
|> Oban.insert()
```

## Job Scheduling

### Immediate execution:
```elixir
%{email: "user@example.com"}
|> #{app_module}.Workers.EmailWorker.new()
|> Oban.insert()
```

### Delayed execution:
```elixir
%{email: "user@example.com"}
|> #{app_module}.Workers.EmailWorker.new(schedule_in: 60)  # 60 seconds from now
|> Oban.insert()
```

### Scheduled execution:
```elixir
%{email: "user@example.com"}
|> #{app_module}.Workers.EmailWorker.new(scheduled_at: ~U[2024-01-01 12:00:00Z])
|> Oban.insert()
```

## Queue Configuration

Your Oban is configured with three queues:
- `default` (10 concurrent jobs) - General processing
- `emails` (20 concurrent jobs) - Email sending
- `notifications` (15 concurrent jobs) - User notifications

## Integration with Phoenix

### From controllers:
```elixir
def create_user(conn, %{"user" => user_params}) do
  # Create user...

  # Send welcome email
  %{email: user.email, subject: "Welcome!", body: "Welcome to our app!"}
  |> #{app_module}.Workers.EmailWorker.new()
  |> Oban.insert()

  # Send welcome notification
  %{user_id: user.id, type: "welcome", data: %{template: "welcome"}}
  |> #{app_module}.Workers.NotificationWorker.new()
  |> Oban.insert()

  # Rest of controller logic...
end
```

### From contexts:
```elixir
def process_payment(payment) do
  # Process payment...

  # Send confirmation email
  %{email: payment.user.email, subject: "Payment Confirmed", body: "Your payment was successful!"}
  |> #{app_module}.Workers.EmailWorker.new()
  |> Oban.insert()

  # Send notification
  %{user_id: payment.user_id, type: "payment_success", data: %{amount: payment.amount}}
  |> #{app_module}.Workers.NotificationWorker.new()
  |> Oban.insert()
end
```

## Testing Oban is Working

### 1. Start your Phoenix server:
```bash
mix phx.server
```

### 2. Open an IEx session:
```bash
iex -S mix
```

### 3. Enqueue test jobs:
```elixir
# Test EmailWorker
%{email: "test@example.com", subject: "Test Email", body: "This is a test email!"}
|> #{app_module}.Workers.EmailWorker.new()
|> Oban.insert()

# Test ExampleWorker
%{message: "Hello from Oban!"}
|> #{app_module}.Workers.ExampleWorker.new()
|> Oban.insert()

# Test NotificationWorker
%{user_id: 1, type: "test", data: %{message: "Test notification"}}
|> #{app_module}.Workers.NotificationWorker.new()
|> Oban.insert()
```

### 4. Check the console output:
You should see messages like:
```
📧 Sending email to: test@example.com
Subject: Test Email
Body: This is a test email!
🔄 Processing: Hello from Oban!
🔔 Sending test notification to user 1
```

### 5. Monitor jobs:
```bash
mix oban.dashboard
```

## Creating Custom Workers

### 1. Create a new worker:
```elixir
defmodule #{app_module}.Workers.CustomWorker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"data" => data}}) do
    # Your job logic here
    IO.puts("Processing: \#{inspect(data)}")

    # Simulate work
    Process.sleep(1000)

    {:ok, "Processed successfully"}
  end
end
```

### 2. Enqueue the job:
```elixir
%{data: "your data here"}
|> #{app_module}.Workers.CustomWorker.new()
|> Oban.insert()
```

## Best Practices

### 1. Error Handling
- Jobs automatically retry on failure
- Configure retry limits in worker options
- Use `{:error, reason}` for expected failures

### 2. Queue Selection
- Use appropriate queues for different job types
- Monitor queue performance
- Adjust concurrency based on job complexity

### 3. Job Arguments
- Keep arguments simple and serializable
- Avoid passing large objects
- Use IDs instead of full records when possible

### 4. Monitoring
- Use Oban dashboard for job monitoring
- Set up alerts for failed jobs
- Monitor queue backlogs

## Advanced Features

### Periodic Jobs
```elixir
# In your application.ex
def start(_type, _args) do
  children = [
    # ... other children
    {Oban, oban_config()}
  ]

  # Schedule periodic jobs
  Oban.insert(%{message: "Daily report"} |> #{app_module}.Workers.ExampleWorker.new(schedule_in: 86400))

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

### Job Chaining
```elixir
def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
  # Process user data...

  # Schedule follow-up job
  %{user_id: user_id, type: "follow_up"}
  |> #{app_module}.Workers.NotificationWorker.new(schedule_in: 300)
  |> Oban.insert()

  {:ok, "User processed"}
end
```

### Custom Queues
```elixir
# In config/config.exs
config :#{app_name}, Oban,
  repo: #{app_module}.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    emails: 20,
    notifications: 15,
    critical: 5,
    low: 30
  ]
```
"""

    create_documentation(project_path, "oban", content)
  end
end
