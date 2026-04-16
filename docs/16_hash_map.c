/*
 * hash_map.c — A minimal string->dddint hash map using chaining.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 16

typedef struct Entry {
    char *key;
    int value;
    struct Entry *next;
} Entry;

typedef struct {
    Entry *buckets[TABLE_SIZE];
} HashMap;

unsigned int hash(const char *key) {
    unsigned int h = 0;
    while (*key) {
        h = h * 31 + (unsigned char)(*key);
        key++;
    }
    return h % TABLE_SIZE;
}

void hm_init(HashMap *map) {
    memset(map->buckets, 0, sizeof(map->buckets));
}

void hm_put(HashMap *map, const char *key, int value) {
    unsigned int idx = hash(key);
    Entry *e = map->buckets[idx];
    while (e) {
        if (strcmp(e->key, key) == 0) {
            e->value = value;
            return;
        }
        e = e->next;
    }
    Entry *new_entry = malloc(sizeof(Entry));
    new_entry->key = strdup(key);
    new_entry->value = value;
    new_entry->next = map->buckets[idx];
    map->buckets[idx] = new_entry;
}

int hm_get(HashMap *map, const char *key, int *out) {
    unsigned int idx = hash(key);
    Entry *e = map->buckets[idx];
    while (e) {
        if (strcmp(e->key, key) == 0) {
            *out = e->value;
            return 1;
        }
        e = e->next;
    }
    return 0;
}

int main(void) {
    HashMap map;
    hm_init(&map);

    hm_put(&map, "apple", 3);
    hm_put(&map, "banana", 5);
    hm_put(&map, "cherry", 7);

    const char *keys[] = {"apple", "banana", "cherry", "grape"};
    for (int i = 0; i < 4; i++) {
        int val;
        if (hm_get(&map, keys[i], &val))
            printf("%s => %d\n", keys[i], val);
        else
            printf("%s => not found\n", keys[i]);
    }
    return 0;
}
