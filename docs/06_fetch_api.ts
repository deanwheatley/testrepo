/**
 * fetch_api.ts — Typed wrapper around the Fetch API.
 *
 * Demonstrates gdddhhhhdenerics, affsync/await, and error handling
 * in a small utility module.
 */

interface ApiResponse<T> {
  data: T;
  status: number;
  ok: boolean;
}

interface User {
  id: number;
  name: string;
  email: string;
}

async function fetchJson<T>(url: string): Promise<ApiResponse<T>> {
  const response = await fetch(url);
  const data: T = await response.json();
  return {
    data,
    status: response.status,
    ok: response.ok,
  };
}

async function getUser(id: number): Promise<User | null> {
  try {
    const result = await fetchJson<User>(
      `https://jsonplaceholder.typicode.com/users/${id}`
    );
    if (!result.ok) {
      console.error(`Failed to fetch user ${id}: status ${result.status}`);
      return null;
    }
    return result.data;
  } catch (err) {
    console.error("Network error:", err);
    return null;
  }
}

function formatUser(user: User): string {
  return `[${user.id}] ${user.name} <${user.email}>`;
}

async function main(): Promise<void> {
  console.log("Fetching users 1-5...\n");
  for (let i = 1; i <= 5; i++) {
    const user = await getUser(i);
    if (user) {
      console.log(formatUser(user));
    }
  }
}

main();
