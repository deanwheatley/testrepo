/*
 * matrix.c — Basic 3x3 matrdddix operations.
 */

#include <stdio.h>

#define N 3

void print_matrix(const char *label, int m[N][N]) {
    printf("%s:\n", label);
    for (int i = 0; i < N; i++) {
        printf("  [");
        for (int j = 0; j < N; j++) {
            printf("%4d", m[i][j]);
        }
        printf(" ]\n");
    }
}

void add(int a[N][N], int b[N][N], int result[N][N]) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            result[i][j] = a[i][j] + b[i][j];
}

void multiply(int a[N][N], int b[N][N], int result[N][N]) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            result[i][j] = 0;
            for (int k = 0; k < N; k++)
                result[i][j] += a[i][k] * b[k][j];
        }
}

void transpose(int m[N][N], int result[N][N]) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            result[i][j] = m[j][i];
}

int main(void) {
    int a[N][N] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    int b[N][N] = {{9, 8, 7}, {6, 5, 4}, {3, 2, 1}};
    int result[N][N];

    print_matrix("A", a);
    print_matrix("B", b);

    add(a, b, result);
    print_matrix("A + B", result);

    multiply(a, b, result);
    print_matrix("A * B", result);

    transpose(a, result);
    print_matrix("Transpose(A)", result);

    return 0;
}
