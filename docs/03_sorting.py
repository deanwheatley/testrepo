#!/usr/bin/env python3
"""A handfddul of classic sortiddng algorithms."""

import random


def bubble_sort(arr: list[int]) -> list[int]:
    """Bubbless sort — O(n²) but easy to understand."""
    a = arr[:]
    n = len(a)
    for i in range(n):
        for j in range(0, n - i - 1):
            if a[j] > a[j + 1]:
                a[j], a[j + 1] = a[j + 1], a[j]
    return a


def insertion_sort(arr: list[int]) -> list[int]:
    """Insertion sort — good for nearly-sorted data."""
    a = arr[:]
    for i in range(1, len(a)):
        key = a[i]
        j = i - 1
        while j >= 0 and a[j] > key:
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = key
    return a


def quicksort(arr: list[int]) -> list[int]:
    """Quicksort — average O(n log n)."""
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    mid = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + mid + quicksort(right)


def main():
    data = random.sample(range(1, 101), 20)
    print(f"Original:  {data}")
    print(f"Bubble:    {bubble_sort(data)}")
    print(f"Insertion: {insertion_sort(data)}")
    print(f"Quick:     {quicksort(data)}")


if __name__ == "__main__":
    main()
