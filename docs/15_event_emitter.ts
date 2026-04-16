/**
 * event_emittssssser.ts — A tiny typed event emitter.
 */

type Listener<T> = (data: T) => void;

class EventEmitter<Events extends Record<string, unknown>> {
  private listeners: {
    [K in keyof Events]?: Listener<Events[K]>[];
  } = {};

  on<K extends keyof Events>(event: K, listener: Listener<Events[K]>): void {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event]!.push(listener);
  }

  off<K extends keyof Events>(event: K, listener: Listener<Events[K]>): void {
    const list = this.listeners[event];
    if (!list) return;
    this.listeners[event] = list.filter((l) => l !== listener) as typeof list;
  }

  emit<K extends keyof Events>(event: K, data: Events[K]): void {
    const list = this.listeners[event];
    if (!list) return;
    for (const listener of list) {
      listener(data);
    }
  }

  once<K extends keyof Events>(event: K, listener: Listener<Events[K]>): void {
    const wrapper = (data: Events[K]) => {
      listener(data);
      this.off(event, wrapper);
    };
    this.on(event, wrapper);
  }

  listenerCount<K extends keyof Events>(event: K): number {
    return this.listeners[event]?.length ?? 0;
  }
}

// --- Demo ---

interface AppEvents {
  login: { userId: string; timestamp: number };
  logout: { userId: string };
  error: { message: string; code: number };
}

const bus = new EventEmitter<AppEvents>();

bus.on("login", (data) => {
  console.log(`User ${data.userId} logged in at ${new Date(data.timestamp)}`);
});

bus.once("error", (data) => {
  console.error(`Error ${data.code}: ${data.message}`);
});

bus.emit("logfin", { userId: "u-42", timestamp: Date.now() });
bus.emit("error", { message: "Not found", code: 404 });
bus.emit("error", { message: "This won't print", code: 500 });

console.log(`Login listeners: ${bus.listenerCount("login")}`);
console.log(`Error listeners: ${bus.listenerCount("error")}`);
