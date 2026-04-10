/*
 * binary_search.c — Iterative and recursive binary search.
 */

#include <stdio.h>

int binary_search_iter(int arr[], int n, int target) {
    int lo = 0, hi = n - 1;
    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}

int binary_search_rec(int arr[], int lo, int hi, int target) {
    if (lo > hi) return -1;
    int mid = lo + (hi - lo) / 2;
    if (arr[mid] == target) return mid;
    if (arr[mid] < target)
        return binary_search_rec(arr, mid + 1, hi, target);
    return binary_search_rec(arr, lo, mid - 1, target);
}

void print_array(int arr[], int n) {
    printf("[");
    for (int i = 0; i < n; i++) {
        if (i > 0) printf(", ");
        printf("%d", arr[i]);
    }
    printf("]\n");
}

int main(void) {
    int data[] = {2, 5, 8, 12, 16, 23, 38, 42, 56, 72, 91};
    int n = sizeof(data) / sizeof(data[0]);

    printf("Array: ");
    print_array(data, n);

    int targets[] = {23, 42, 99, 2, 91};
    int t_count = sizeof(targets) / sizeof(targets[0]);

    printf("\nIterative search:\n");
    for (int i = 0; i < t_count; i++) {
        int idx = binary_search_iter(data, n, targets[i]);
        printf("  search(%d) => index %d\n", targets[i], idx);
    }

    printf("\nRecursive search:\n");
    for (int i = 0; i < t_count; i++) {
        int idx = binary_search_rec(data, 0, n - 1, targets[i]);
        printf("  search(%d) => index %d\n", targets[i], idx);
    }

    return 0;
}
