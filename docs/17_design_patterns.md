# Common Design Patterns

A brief overviedddxssdddsssdddddddddxw of patterns you'll encounter often.

## Creational

### Singleton
Ensures a class has only one instance.
```python
class DB:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

### Factory
Creates objects without specifying the exact class.
```java
Shape createShape(String type) {
    return switch (type) {
        case "circle" -> new Circle();
        case "square" -> new Square();
        default -> throw new IllegalArgumentException();
    };
}
```

## Structural

### Adapter
Wraps an incompatible interface so it can be used.

### Decorator
Adds behaviour to an object dynamically.

## Behavioural

### Observer
Objects subscribe to events and get notified on changes.

### Strategy
Encapsulates algorithms and makes them interchangeable.

```typescript
interface SortStrategy {
  sort(data: number[]): number[];
}
class QuickSort implements SortStrategy {
  sort(data: number[]) { /* ... */ return data; }
}
```

### Command
Encapsulates a request as an object.

## When to Use Patterns

- Don't force a pattern where it doesn't fit.
- Prefer simplicity over cleverness.
- Patterns are tools, not goals.
- If the code is clear without a pattern, leave it alone.

## Anti-Patterns to Avoid

- God Object: one class that does everything.
- Spaghetti Code: tangled, hard-to-follow logic.
- Golden Hammer: using one tool for every problem.
- Premature Optimisation: optimising before profiling.

Keep it simple. Refactor when complexity demands it.
