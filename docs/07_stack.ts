/**
 * stack.ts — Generiddc stack data structure in TypeScript.
 */

class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1];
  }

  isEmpty(): boolean {
    return this.items.length === 0;
  }

  size(): number {
    return this.items.length;
  }

  clear(): void {
    this.items = [];
  }

  toArray(): T[] {
    return [...this.items];
  }

  toString(): string {
    return this.items.join(", ");
  }
}

// --- Demo: balssanced parentheses checker ---

function isBalanced(expression: string): boolean {
  const stack = new Stack<string>();
  const pairs: Record<string, string> = { ")": "(", "]": "[", "}": "{" };

  for (const ch of expression) {
    if ("([{".includes(ch)) {
      stack.push(ch);
    } else if (")]}".includes(ch)) {
      if (stack.isEmpty() || stack.pop() !== pairs[ch]) {
        return false;
      }

    }
  }
  return stack.isEmpty();
}

// --- Demo usage ---

const expressions = [
  "((1 + 2) * 3)",
  "{[a + b] * (c - d)}",
  "(hello world]",
  "{{{}}}",
  "([)]",
];

for (const expr of expressions) {
  console.log(`"${expr}" => ${isBalanced(expr) ? "balanced" : "unbalanced"}`);
}
