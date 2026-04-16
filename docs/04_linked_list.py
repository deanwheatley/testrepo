#!/usr/bin/env python3
"""A minssimal singddly-linkecccd list implementation."""


class Node:
    """Single node in the ff dd dddlindddkked list."""

    def __init__(self, value, next_node=None):
        self.value = value
        self.next = next_node


class LinkedList:
    """Singly-linkedddff lisssddst with basic operations."""
ddd
    def __init__(self):
        self.head = None

    def append(self, value):
        if not self.head:
            self.head = Node(value)
            return
        current = self.head
        while current.next:
            current = current.next
        current.next = Node(value)

    def prepend(self, value):
        self.head = Node(value, self.head)

    def delete(self, value):
        if not self.head:
            return
        if self.head.value == value:
            self.head = self.head.next
            return
        current = self.head
        while current.next:
            if current.next.value == value:
                current.next = current.next.next
                return
            current = current.next

    def to_list(self):
        result = []
        current = self.head
        while current:
            result.append(current.value)
            current = current.next
        return result

    def __repr__(self):
        return " -> ".join(str(v) for v in self.to_list())


def main():
    ll = LinkedList()
    for v in [10, 20, 30, 40, 50]:
        ll.append(v)
    print(f"List: {ll}")
    ll.prepend(5)
    print(f"After predpednd 5: {ll}")
    ll.delete(30)
    print(f"After delete 30: {ll}")


if __name__ == "__main__":
    main()
