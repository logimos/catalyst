defmodule Catalyst.Modules.Swoosh do
  @moduledoc """
  Configures Swoosh for email functionality in the Phoenix application.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    inject_dependency: 2,
    create_documentation: 3
  ]

  def setup(project_path) do
    inject_dependency(project_path, {:swoosh, "~> 1.11"})
    create_mailer(project_path)
    create_email_templates(project_path)
    create_documentation(project_path)
    System.cmd("mix", ["deps.get"], cd: project_path)
    :ok
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp create_mailer(project_path) do
    app_name = Path.basename(project_path)
    lib_dir = Path.join([project_path, "lib", app_name])
    mailers_dir = Path.join(lib_dir, "mailers")
    File.mkdir_p!(mailers_dir)

    app_module = Macro.camelize(app_name)

    create_file_from_template(mailers_dir, "mailer.ex", """
defmodule #{app_module}.Mailer do
  use Swoosh.Mailer, otp_app: :#{app_name}
end
""")

    create_file_from_template(mailers_dir, "email_sender.ex", """
defmodule #{app_module}.Mailers.EmailSender do
  @moduledoc \"\"\"
  Email sender for common email types.
  \"\"\"

  import Swoosh.Email
  alias #{app_module}.Mailer

  def welcome_email(user_email, user_name) do
    new()
    |> to(user_email)
    |> from({"\#{app_module}", "noreply@\#{app_name}.com"})
    |> subject("Welcome to #{app_module}!")
    |> html_body(\"\"\"
      <h1>Welcome \#{user_name}!</h1>
      <p>Thank you for joining #{app_module}.</p>
      <p>We're excited to have you on board!</p>
    \"\"\")
    |> text_body(\"\"\"
      Welcome \#{user_name}!

      Thank you for joining #{app_module}.
      We're excited to have you on board!
    \"\"\")
    |> Mailer.deliver()
  end

  def password_reset_email(user_email, reset_token) do
    reset_url = "https://#{app_name}.com/reset-password?token=\#{reset_token}"

    new()
    |> to(user_email)
    |> from({"#{app_module}", "noreply@#{app_name}.com"})
    |> subject("Reset Your Password")
    |> html_body(\"\"\"
      <h1>Reset Your Password</h1>
      <p>Click the link below to reset your password:</p>
      <a href="\#{reset_url}">Reset Password</a>
      <p>If you didn't request this, please ignore this email.</p>
    \"\"\")
    |> text_body(\"\"\"
      Reset Your Password

      Click the link below to reset your password:
      \#{reset_url}

      If you didn't request this, please ignore this email.
    \"\"\")
    |> Mailer.deliver()
  end

  def notification_email(user_email, subject, message) do
    new()
    |> to(user_email)
    |> from({"#{app_module}", "noreply@#{app_name}.com"})
    |> subject(subject)
    |> html_body(\"\"\"
      <h1>\#{subject}</h1>
      <p>\#{message}</p>
    \"\"\")
    |> text_body(\"\"\"
      \#{subject}

      \#{message}
    \"\"\")
    |> Mailer.deliver()
  end
end
""")
  end

  defp create_email_templates(project_path) do
    app_name = Path.basename(project_path)
    templates_dir = Path.join([project_path, "lib", "#{app_name}_web", "controllers", "email_html"])
    File.mkdir_p!(templates_dir)

    create_file_from_template(templates_dir, "welcome.html.heex", """
<div class="email-container">
  <h1>Welcome to <%= @app_name %>!</h1>
  <p>Hello <%= @user_name %>,</p>
  <p>Thank you for joining our platform. We're excited to have you on board!</p>
  <p>If you have any questions, feel free to reach out to our support team.</p>
  <p>Best regards,<br>The <%= @app_name %> Team</p>
</div>
""")

    create_file_from_template(templates_dir, "password_reset.html.heex", """
<div class="email-container">
  <h1>Reset Your Password</h1>
  <p>Hello,</p>
  <p>You requested to reset your password. Click the button below to proceed:</p>
  <a href="<%= @reset_url %>" class="button">Reset Password</a>
  <p>If you didn't request this password reset, please ignore this email.</p>
  <p>This link will expire in 24 hours.</p>
  <p>Best regards,<br>The <%= @app_name %> Team</p>
</div>
""")
  end

  defp create_documentation(project_path) do
    app_name = Path.basename(project_path)
    app_module = Macro.camelize(app_name)

    markdown_content = """
# Swoosh Email Integration

Catalyst has integrated Swoosh for email functionality in your Phoenix application.

## Changes Made:
- Added Swoosh dependency to `mix.exs`
- Created mailer configuration
- Generated email sender module with common email types
- Added email templates

## Email Sender

Located in `lib/#{app_name}/mailers/email_sender.ex`

Features:
- **Welcome emails** - New user onboarding
- **Password reset emails** - Secure password recovery
- **Notification emails** - General notifications
- **HTML and text versions** - Multi-format support

## Basic Usage

### Send Welcome Email:
```elixir
alias #{app_module}.Mailers.EmailSender

case EmailSender.welcome_email("user@example.com", "John Doe") do
  {:ok, _email} ->
    IO.puts("Welcome email sent successfully!")
  {:error, reason} ->
    IO.puts("Failed to send email: \#{reason}")
end
```

### Send Password Reset:
```elixir
reset_token = "abc123def456"
case EmailSender.password_reset_email("user@example.com", reset_token) do
  {:ok, _email} ->
    IO.puts("Password reset email sent!")
  {:error, reason} ->
    IO.puts("Failed to send reset email: \#{reason}")
end
```

### Send Custom Notification:
```elixir
case EmailSender.notification_email("user@example.com", "Important Update", "Your account has been updated.") do
  {:ok, _email} ->
    IO.puts("Notification sent!")
  {:error, reason} ->
    IO.puts("Failed to send notification: \#{reason}")
end
```

## Testing Emails

### 1. Start your Phoenix server:
```bash
mix phx.server
```

### 2. Open an IEx session:
```bash
iex -S mix
```

### 3. Test email sending:
```elixir
alias #{app_module}.Mailers.EmailSender

# Test welcome email
EmailSender.welcome_email("test@example.com", "Test User")

# Test password reset
EmailSender.password_reset_email("test@example.com", "test-token-123")

# Test notification
EmailSender.notification_email("test@example.com", "Test Subject", "Test message")
```

## Configuration

### Development (Local):
```elixir
# In config/dev.exs
config :#{app_name}, #{app_module}.Mailer,
  adapter: Swoosh.Adapters.Local
```

### Production (SMTP):
```elixir
# In config/prod.exs
config :#{app_name}, #{app_module}.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.gmail.com",
  port: 587,
  username: "your-email@gmail.com",
  password: "your-app-password",
  tls: :always,
  auth: :always,
  retries: 2
```

### SendGrid:
```elixir
# Add to mix.exs
{:swoosh, "~> 1.11"}

# In config/prod.exs
config :#{app_name}, #{app_module}.Mailer,
  adapter: Swoosh.Adapters.SendGrid,
  api_key: "your-sendgrid-api-key"
```

### Amazon SES:
```elixir
# Add to mix.exs
{:swoosh, "~> 1.11"}

# In config/prod.exs
config :#{app_name}, #{app_module}.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "us-east-1",
  access_key_id: "your-access-key",
  secret_access_key: "your-secret-key"
```

## Custom Email Templates

### Create a new email type:
```elixir
def order_confirmation_email(user_email, order) do
  new()
  |> to(user_email)
  |> from({"#{app_module}", "orders@#{app_name}.com"})
  |> subject("Order Confirmation - #\#{order.id}")
  |> html_body(\"\"\"
    <h1>Order Confirmed!</h1>
    <p>Your order #\#{order.id} has been confirmed.</p>
    <p>Total: $\#{order.total}</p>
  \"\"\")
  |> text_body(\"\"\"
    Order Confirmed!

    Your order #\#{order.id} has been confirmed.
    Total: $\#{order.total}
  \"\"\")
  |> Mailer.deliver()
end
```

### Use in controllers:
```elixir
def create_order(conn, %{"order" => order_params}) do
  case Orders.create_order(order_params) do
    {:ok, order} ->
      # Send confirmation email
      EmailSender.order_confirmation_email(current_user.email, order)

      conn
      |> put_flash(:info, "Order created successfully!")
      |> redirect(to: ~p"/orders/\#{order}")
    {:error, changeset} ->
      render(conn, :new, changeset: changeset)
  end
end
```

## Background Job Integration

### With Oban:
```elixir
defmodule #{app_module}.Workers.EmailWorker do
  use Oban.Worker, queue: :emails

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "welcome", "email" => email, "name" => name}}) do
    EmailSender.welcome_email(email, name)
  end

  def perform(%Oban.Job{args: %{"type" => "reset", "email" => email, "token" => token}}) do
    EmailSender.password_reset_email(email, token)
  end
end

# Enqueue email job
%{type: "welcome", email: "user@example.com", name: "John"}
|> EmailWorker.new()
|> Oban.insert()
```

## Best Practices

### 1. Email Content
- Always provide both HTML and text versions
- Use clear, concise subject lines
- Include unsubscribe links for marketing emails
- Test emails across different clients

### 2. Security
- Use environment variables for sensitive credentials
- Implement rate limiting for email sending
- Validate email addresses before sending
- Use HTTPS for email links

### 3. Performance
- Send emails asynchronously with background jobs
- Use email templates for consistency
- Monitor email delivery rates
- Implement retry logic for failed sends

### 4. Testing
- Use Swoosh.Test for unit testing
- Test email content and formatting
- Verify email delivery in integration tests
- Use email preview in development

## Advanced Features

### Email Templates with Phoenix:
```elixir
def welcome_email(user_email, user_name) do
  html_content = Phoenix.View.render_to_string(
    #{app_module}Web.EmailView,
    "welcome.html",
    user_name: user_name,
    app_name: "#{app_module}"
  )

  new()
  |> to(user_email)
  |> from({"#{app_module}", "noreply@#{app_name}.com"})
  |> subject("Welcome!")
  |> html_body(html_content)
  |> Mailer.deliver()
end
```

### Email Attachments:
```elixir
def invoice_email(user_email, invoice_pdf) do
  new()
  |> to(user_email)
  |> from({"#{app_module}", "billing@#{app_name}.com"})
  |> subject("Your Invoice")
  |> html_body("<h1>Your invoice is attached</h1>")
  |> attachment(%{
    filename: "invoice.pdf",
    data: invoice_pdf,
    type: "application/pdf"
  })
  |> Mailer.deliver()
end
```

### Email Scheduling:
```elixir
# Schedule email for later
%{type: "reminder", email: "user@example.com"}
|> EmailWorker.new(schedule_in: 3600)  # 1 hour from now
|> Oban.insert()
```
"""

    create_documentation(project_path, "swoosh", markdown_content)
  end
end
