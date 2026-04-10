#!/usr/bin/env python3
"""Simple document viewer — lists files in docs/ and displays the chosen one."""

import os
import sys

DOCS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "docs")


def main():
    if not os.path.isdir(DOCS_DIR):
        print("No docs/ folder found.")
        sys.exit(1)

    files = sorted(f for f in os.listdir(DOCS_DIR) if os.path.isfile(os.path.join(DOCS_DIR, f)))
    if not files:
        print("The docs/ folder is empty.")
        sys.exit(1)

    print("\n=== Document Viewer ===\n")
    for i, name in enumerate(files, 1):
        print(f"  {i}. {name}")

    print()
    choice = input("Enter the number of the file to view (or 'q' to quit): ").strip()
    if choice.lower() == "q":
        sys.exit(0)

    try:
        idx = int(choice) - 1
        if idx < 0 or idx >= len(files):
            raise ValueError
    except ValueError:
        print("Invalid selection.")
        sys.exit(1)

    filepath = os.path.join(DOCS_DIR, files[idx])
    print(f"\n--- {files[idx]} ---\n")
    with open(filepath, "r") as f:
        print(f.read())


if __name__ == "__main__":
    main()
