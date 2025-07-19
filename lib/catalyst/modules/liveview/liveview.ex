defmodule Catalyst.Modules.LiveView do
  @moduledoc """
  Configures Phoenix LiveView with interactive examples and real-time features.
  """

  import Catalyst.Modules.Utils, only: [
    create_file_from_template: 3,
    create_documentation: 3
  ]

  def setup(project_path) do
    try do
      create_liveview_examples(project_path)
      create_liveview_router(project_path)
      create_liveview_templates(project_path)
      create_liveview_documentation(project_path)
      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp create_liveview_examples(project_path) do
    app_name = Path.basename(project_path)
    live_dir = Path.join([project_path, "lib", "#{app_name}_web", "live"])
    File.mkdir_p!(live_dir)

    # Create a counter example
    counter_live = """
defmodule #{Macro.camelize(app_name)}Web.CounterLive do
  use #{Macro.camelize(app_name)}Web, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0, input_value: "")}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, count: 0)}
  end

  def handle_event("update-input", %{"value" => value}, socket) do
    {:noreply, assign(socket, input_value: value)}
  end

  def handle_event("set-count", _params, socket) do
    case Integer.parse(socket.assigns.input_value) do
      {count, _} -> {:noreply, assign(socket, count: count, input_value: "")}
      :error -> {:noreply, socket}
    end
  end
end
"""

    create_file_from_template(live_dir, "counter_live.ex", counter_live)

    # Create a chat example
    chat_live = """
defmodule #{Macro.camelize(app_name)}Web.ChatLive do
  use #{Macro.camelize(app_name)}Web, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(#{Macro.camelize(app_name)}.PubSub, "chat")
    end

    {:ok, assign(socket, messages: [], new_message: "")}
  end

  def handle_event("send-message", _params, socket) do
    if socket.assigns.new_message != "" do
      message = %{
        id: System.unique_integer([:positive]),
        text: socket.assigns.new_message,
        timestamp: DateTime.utc_now()
      }

      Phoenix.PubSub.broadcast(
        #{Macro.camelize(app_name)}.PubSub,
        "chat",
        {:new_message, message}
      )

      {:noreply, assign(socket, new_message: "")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update-message", %{"value" => value}, socket) do
    {:noreply, assign(socket, new_message: value)}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end
end
"""

    create_file_from_template(live_dir, "chat_live.ex", chat_live)

    # Create a todo example
    todo_live = """
defmodule #{Macro.camelize(app_name)}Web.TodoLive do
  use #{Macro.camelize(app_name)}Web, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, todos: [], new_todo: "", filter: "all")}
  end

  def handle_event("add-todo", _params, socket) do
    if socket.assigns.new_todo != "" do
      todo = %{
        id: System.unique_integer([:positive]),
        text: socket.assigns.new_todo,
        completed: false,
        created_at: DateTime.utc_now()
      }

      {:noreply, assign(socket, todos: [todo | socket.assigns.todos], new_todo: "")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle-todo", %{"id" => id}, socket) do
    todos = Enum.map(socket.assigns.todos, fn todo ->
      if todo.id == String.to_integer(id) do
        %{todo | completed: !todo.completed}
      else
        todo
      end
    end)

    {:noreply, assign(socket, todos: todos)}
  end

  def handle_event("delete-todo", %{"id" => id}, socket) do
    todos = Enum.reject(socket.assigns.todos, fn todo ->
      todo.id == String.to_integer(id)
    end)

    {:noreply, assign(socket, todos: todos)}
  end

  def handle_event("update-todo", %{"value" => value}, socket) do
    {:noreply, assign(socket, new_todo: value)}
  end

  def handle_event("set-filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, filter: filter)}
  end

  def filtered_todos(todos, "all"), do: todos
  def filtered_todos(todos, "active"), do: Enum.reject(todos, & &1.completed)
  def filtered_todos(todos, "completed"), do: Enum.filter(todos, & &1.completed)
end
"""

    create_file_from_template(live_dir, "todo_live.ex", todo_live)
  end

  defp create_liveview_router(project_path) do
    app_name = Path.basename(project_path)
    router_file = Path.join([project_path, "lib", "#{app_name}_web", "router.ex"])

    # Read the current router
    content = File.read!(router_file)

    # Add LiveView routes
    live_routes = """
  # LiveView routes
  live "/counter", CounterLive
  live "/chat", ChatLive
  live "/todo", TodoLive
"""

    # Insert after the existing routes but before the end
    updated_content = String.replace(content, ~r/(  # Add more live routes here)/, "\\1\n#{live_routes}")
    File.write!(router_file, updated_content)
  end

  defp create_liveview_templates(project_path) do
    app_name = Path.basename(project_path)
    templates_dir = Path.join([project_path, "lib", "#{app_name}_web", "live"])
    File.mkdir_p!(templates_dir)

    # Counter template
    counter_template = """
<div class="max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-md">
  <h1 class="text-2xl font-bold text-center mb-6">LiveView Counter</h1>

  <div class="text-center mb-6">
    <span class="text-4xl font-bold text-blue-600"><%= @count %></span>
  </div>

  <div class="flex justify-center space-x-4 mb-6">
    <button phx-click="decrement" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">
      -
    </button>
    <button phx-click="reset" class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
      Reset
    </button>
    <button phx-click="increment" class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
      +
    </button>
  </div>

  <div class="text-center">
    <input
      type="number"
      value={@input_value}
      phx-keyup="update-input"
      phx-value-value={@input_value}
      placeholder="Set count..."
      class="px-3 py-2 border rounded mr-2"
    />
    <button phx-click="set-count" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
      Set
    </button>
  </div>
</div>
"""

    create_file_from_template(templates_dir, "counter_live.html.heex", counter_template)

    # Chat template
    chat_template = """
<div class="max-w-2xl mx-auto mt-8">
  <h1 class="text-2xl font-bold text-center mb-6">LiveView Chat</h1>

  <div class="bg-white rounded-lg shadow-md p-6">
    <div class="h-96 overflow-y-auto mb-4 border rounded p-4">
      <%= for message <- @messages do %>
        <div class="mb-2 p-2 bg-gray-100 rounded">
          <div class="text-sm text-gray-600">
            <%= Calendar.strftime(message.timestamp, "%H:%M:%S") %>
          </div>
          <div><%= message.text %></div>
        </div>
      <% end %>
    </div>

    <form phx-submit="send-message" class="flex">
      <input
        type="text"
        value={@new_message}
        phx-keyup="update-message"
        phx-value-value={@new_message}
        placeholder="Type a message..."
        class="flex-1 px-3 py-2 border rounded-l"
      />
      <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-r hover:bg-blue-600">
        Send
      </button>
    </form>
  </div>
</div>
"""

    create_file_from_template(templates_dir, "chat_live.html.heex", chat_template)

    # Todo template
    todo_template = """
<div class="max-w-md mx-auto mt-8">
  <h1 class="text-2xl font-bold text-center mb-6">LiveView Todo</h1>

  <div class="bg-white rounded-lg shadow-md p-6">
    <form phx-submit="add-todo" class="mb-6">
      <div class="flex">
        <input
          type="text"
          value={@new_todo}
          phx-keyup="update-todo"
          phx-value-value={@new_todo}
          placeholder="Add a todo..."
          class="flex-1 px-3 py-2 border rounded-l"
        />
        <button type="submit" class="px-4 py-2 bg-green-500 text-white rounded-r hover:bg-green-600">
          Add
        </button>
      </div>
    </form>

    <div class="mb-4">
      <div class="flex space-x-2">
        <button phx-click="set-filter" phx-value-filter="all" class="px-3 py-1 rounded <%= if @filter == "all", do: "bg-blue-500 text-white", else: "bg-gray-200" %>">
          All
        </button>
        <button phx-click="set-filter" phx-value-filter="active" class="px-3 py-1 rounded <%= if @filter == "active", do: "bg-blue-500 text-white", else: "bg-gray-200" %>">
          Active
        </button>
        <button phx-click="set-filter" phx-value-filter="completed" class="px-3 py-1 rounded <%= if @filter == "completed", do: "bg-blue-500 text-white", else: "bg-gray-200" %>">
          Completed
        </button>
      </div>
    </div>

    <div class="space-y-2">
      <%= for todo <- filtered_todos(@todos, @filter) do %>
        <div class="flex items-center p-2 border rounded">
          <input
            type="checkbox"
            checked={todo.completed}
            phx-click="toggle-todo"
            phx-value-id={todo.id}
            class="mr-3"
          />
          <span class="flex-1 <%= if todo.completed, do: "line-through text-gray-500" %>">
            <%= todo.text %>
          </span>
          <button phx-click="delete-todo" phx-value-id={todo.id} class="text-red-500 hover:text-red-700">
            ×
          </button>
        </div>
      <% end %>
    </div>
  </div>
</div>
"""

    create_file_from_template(templates_dir, "todo_live.html.heex", todo_template)
  end

  defp create_liveview_documentation(project_path) do
    content = """
# LiveView Setup

Catalyst has integrated Phoenix LiveView with interactive examples demonstrating real-time features.

## What was added:
- Three LiveView examples: Counter, Chat, and Todo
- LiveView routes in the router
- Interactive templates with Tailwind CSS styling
- Real-time PubSub communication

## Available Examples

### 1. Counter LiveView
**Route**: `/counter`

A simple counter with increment, decrement, reset, and custom value setting.

**Features:**
- Real-time counter updates
- Input validation
- Responsive design

### 2. Chat LiveView
**Route**: `/chat`

A real-time chat application using Phoenix PubSub.

**Features:**
- Real-time message broadcasting
- Timestamp display
- Auto-scrolling chat window

### 3. Todo LiveView
**Route**: `/todo`

A full-featured todo application with filtering.

**Features:**
- Add, toggle, and delete todos
- Filter by status (All, Active, Completed)
- Persistent state during session

## LiveView Concepts Demonstrated

### Event Handling
```elixir
def handle_event("increment", _params, socket) do
  {:noreply, assign(socket, count: socket.assigns.count + 1)}
end
```

### PubSub Communication
```elixir
# Subscribe to a topic
Phoenix.PubSub.subscribe(YourApp.PubSub, "chat")

# Broadcast to a topic
Phoenix.PubSub.broadcast(YourApp.PubSub, "chat", {:new_message, message})
```

### Template Binding
```heex
<button phx-click="increment" class="btn">
  Increment
</button>
```

## Testing the Examples

### 1. Start your Phoenix server:
```bash
mix phx.server
```

### 2. Visit the examples:
- **Counter**: http://localhost:4000/counter
- **Chat**: http://localhost:4000/chat
- **Todo**: http://localhost:4000/todo

### 3. Test real-time features:
- Open multiple browser tabs to test chat
- Use the counter with multiple users
- Create and manage todos

## LiveView Best Practices

### 1. State Management
- Keep state minimal and focused
- Use `assign/3` for updates
- Avoid storing large objects in socket

### 2. Event Handling
- Use descriptive event names
- Validate input data
- Return appropriate responses

### 3. Performance
- Use `phx-debounce` for frequent events
- Implement proper cleanup in `handle_info/3`
- Use PubSub sparingly

### 4. Templates
- Keep templates simple and readable
- Use Tailwind CSS for styling
- Implement responsive design

## Creating New LiveViews

### 1. Create the LiveView module:
```elixir
defmodule YourAppWeb.ExampleLive do
  use YourAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, data: [])}
  end

  def handle_event("action", params, socket) do
    # Handle your event
    {:noreply, socket}
  end
end
```

### 2. Add the route:
```elixir
# In router.ex
live "/example", ExampleLive
```

### 3. Create the template:
```heex
<!-- lib/your_app_web/live/example_live.html.heex -->
<div>
  <h1>Your LiveView</h1>
  <!-- Your template content -->
</div>
```

## Integration with Other Modules

### With Authentication
```elixir
def mount(_params, %{"user_token" => user_token}, socket) do
  user = Accounts.get_user_by_session_token(user_token)
  {:ok, assign(socket, current_user: user)}
end
```

### With PubSub
```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(YourApp.PubSub, "your_topic")
  end
  {:ok, socket}
end
```

## Advanced Features

### Periodic Updates
```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    :timer.send_interval(5000, self(), :update)
  end
  {:ok, socket}
end

def handle_info(:update, socket) do
  # Update your data
  {:noreply, socket}
end
```

### File Uploads
```elixir
def handle_event("save", %{"upload" => upload}, socket) do
  # Handle file upload
  {:noreply, socket}
end
```

## Troubleshooting

### Common Issues:
1. **Events not firing**: Check `phx-click` and `phx-submit` attributes
2. **State not updating**: Verify `assign/3` usage
3. **PubSub not working**: Ensure proper topic subscription
4. **Performance issues**: Use debouncing and proper cleanup

### Debugging:
```elixir
# Add to your LiveView for debugging
def handle_event(event, params, socket) do
  IO.inspect({event, params}, label: "Event")
  # Your event handling
end
```
"""

    create_documentation(project_path, "liveview", content)
  end
end
