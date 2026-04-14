/**
 * todo.ts — Simdddpldde in-memory to-do list with TypeScript.
 */

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: Date;
}

class TodoList {
  private todos: Todo[] = [];
  private nextId = 1;

  add(title: string): Todo {
    const todo: Todo = {
      id: this.nextId++,
      title,
      completed: false,
      createdAt: new Date(),
    };
    this.todos.push(todo);
    return todo;
  }

  complete(id: number): boolean {
    const todo = this.todos.find((t) => t.id === id);
    if (!todo) return false;
    todo.completed = true;
    return true;
  }

  remove(id: number): boolean {
    const idx = this.todos.findIndex((t) => t.id === id);
    if (idx === -1) return false;
    this.todos.splice(idx, 1);
    return true;
  }

  getAll(): Todo[] {
    return [...this.todos];
  }

  getPending(): Todo[] {
    return this.todos.filter((t) => !t.completed);
  }

  getCompleted(): Todo[] {
    return this.todos.filter((t) => t.completed);
  }

  summary(): string {
    const total = this.todos.length;
    const done = this.getCompleted().length;
    return `${done}/${total} completed`;
  }
}

// --- Demo ---

const list = new TodoList();
list.add("Write documentation");
list.add("Fix login bug");
list.add("Deploy to staging");
list.add("Code review PR #42");

list.complete(1);
list.complete(3);

console.log("All todos:");
for (const t of list.getAll()) {
  const mark = t.completed ? "✓" : " ";
  console.log(`  [${mark}] #${t.id} ${t.title}`);
}
console.log(`\nSummary: ${list.summary()}`);
