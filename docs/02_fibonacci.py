#!/usr/bin/env python3
"""Generate Fibonacci numbers using several approaches."""


def fib_recursive(n: int) -> int:
    """Classic recursive Fibonacci — simple but slow for large n."""
    if n <= 1:
        return n
    return fib_recursive(n - 1) + fib_recursive(n - 2)


def fib_iterative(n: int) -> int:
    """Iterative version — O(n) time, O(1) space."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_memo(n: int, cache: dict | None = None) -> int:
    """Memoised recursive Fibonacci."""
    if cache is None:
        cache = {}
    if n in cache:
        return cache[n]
    if n <= 1:
        return n
    cache[n] = fib_memo(n - 1, cache) + fib_memo(n - 2, cache)
    return cache[n]


def fib_generator(limit: int):
    """Yield Fibonacci numbers up to a limit."""
    a, b = 0, 1
    while a <= limit:
        yield a
        a, b = b, a + b


def main():
    print("First 20 Fibonacci numbers (iterative):")
    for i in range(20):
        print(f"  F({i}) = {fib_iterative(i)}")

    print("\nFibonacci numbers up to 1000:")
    for num in fib_generator(1000):
        print(f"  {num}", end="")
    print()


if __name__ == "__main__":
    main()
