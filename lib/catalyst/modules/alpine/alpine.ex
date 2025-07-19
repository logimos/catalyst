defmodule Catalyst.Modules.Alpine do
  @moduledoc """
  Configures Alpine.js for interactive frontend functionality in the Phoenix application.
  """

  def setup(project_path) do
    try do
      inject_alpine_js(project_path)
      add_alpine_components(project_path)
      create_documentation(project_path)
      :ok
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp inject_alpine_js(project_path) do
    # Add Alpine.js to the app.js file
    app_js = Path.join(project_path, "assets/js/app.js")
    content = File.read!(app_js)

    # Add Alpine.js import and initialization
    alpine_import = """
import Alpine from 'alpinejs'

// Make Alpine available on window object
window.Alpine = Alpine

// Start Alpine
Alpine.start()
"""

    # Insert Alpine.js after the existing imports but before any existing code
    updated_content = String.replace(content, ~r/(import.*\n+)/, "\\1#{alpine_import}\n")
    File.write!(app_js, updated_content)
  end

  defp add_alpine_components(project_path) do
    # Create a components directory for Alpine.js components
    components_dir = Path.join(project_path, "assets/js/components")
    File.mkdir_p!(components_dir)

    # Create a sample component
    sample_component = """
// Sample Alpine.js component
export function counter() {
  return {
    count: 0,
    increment() {
      this.count++
    },
    decrement() {
      this.count--
    }
  }
}

export function dropdown() {
  return {
    open: false,
    toggle() {
      this.open = !this.open
    },
    close() {
      this.open = false
    }
  }
}

export function form() {
  return {
    loading: false,
    async submit() {
      this.loading = true
      // Form submission logic here
      await new Promise(resolve => setTimeout(resolve, 1000))
      this.loading = false
    }
  }
}
"""

    File.write!(Path.join(components_dir, "alpine-components.js"), sample_component)

    # Update app.js to import components
    app_js = Path.join(project_path, "assets/js/app.js")
    content = File.read!(app_js)

    component_import = """
// Import Alpine.js components
import * as Components from './components/alpine-components.js'

// Register components globally
Object.entries(Components).forEach(([name, component]) => {
  Alpine.data(name, component)
})
"""

    # Add component imports after Alpine.start()
    updated_content = String.replace(content, "Alpine.start()", "Alpine.start()\n#{component_import}")
    File.write!(app_js, updated_content)
  end

  defp create_documentation(project_path) do
    documentation_path = Path.join(project_path, "docs/catalyst")
    File.mkdir_p!(documentation_path)

    content = """
# Alpine.js Setup

Catalyst has integrated Alpine.js into your Phoenix project for lightweight interactive functionality.

## What was added:
- Alpine.js library integration
- Sample components (counter, dropdown, form)
- Component registration system

## Available Components

### Counter Component
```html
<div x-data="counter()">
  <button @click="decrement()">-</button>
  <span x-text="count">0</span>
  <button @click="increment()">+</button>
</div>
```

### Dropdown Component
```html
<div x-data="dropdown()" class="relative">
  <button @click="toggle()">Toggle Menu</button>
  <div x-show="open" @click.away="close()" class="absolute top-full">
    <a href="#" class="block px-4 py-2">Item 1</a>
    <a href="#" class="block px-4 py-2">Item 2</a>
  </div>
</div>
```

### Form Component
```html
<form x-data="form()" @submit.prevent="submit()">
  <input type="email" name="email" required />
  <button type="submit" :disabled="loading">
    <span x-show="!loading">Submit</span>
    <span x-show="loading">Loading...</span>
  </button>
</form>
```

## Alpine.js Directives

### Data Binding
- `x-data` - Initialize component data
- `x-text` - Set text content
- `x-html` - Set HTML content
- `x-bind` - Bind attributes

### Event Handling
- `@click` - Click events
- `@submit` - Form submission
- `@keyup` - Keyboard events
- `@click.away` - Click outside element

### Conditional Rendering
- `x-show` - Show/hide elements
- `x-if` - Conditional rendering
- `x-for` - Loop through arrays

### Transitions
- `x-transition` - Add transitions
- `x-transition:enter` - Enter transition
- `x-transition:leave` - Leave transition

## Creating Custom Components

Add new components to `assets/js/components/alpine-components.js`:

```javascript
export function myComponent() {
  return {
    // Component data and methods
    message: 'Hello Alpine!',
    updateMessage() {
      this.message = 'Updated!'
    }
  }
}
```

## Integration with Phoenix

Alpine.js works seamlessly with Phoenix LiveView and regular Phoenix templates. Use it for:
- Form interactions
- UI state management
- Animations
- Client-side validation
- Interactive components

## Best Practices
- Keep components small and focused
- Use `x-data` for component state
- Leverage `@click.away` for dropdowns
- Use transitions for smooth UX
- Combine with Tailwind CSS for styling
"""

    File.write!(Path.join(documentation_path, "alpine.md"), content)
  end
end
