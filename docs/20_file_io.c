/*
 * file_io.c — Read and write text files in C.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 256

int write_file(const char *path, const char *content) {
    FILE *fp = fopen(path, "w");
    if (!fp) {
        perror("fopen (write)");
        return -1;
    }
    fputs(content, fp);
    fclose(fp);
    return 0;
}

int read_file(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        perror("fopen (read)");
        return -1;
    }
    char line[MAX_LINE];
    int lineno = 1;
    while (fgets(line, sizeof(line), fp)) {
        printf("%3d | %s", lineno++, line);
    }
    fclose(fp);
    return 0;
}

int count_lines(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) return -1;
    int count = 0;
    char line[MAX_LINE];
    while (fgets(line, sizeof(line), fp)) count++;
    fclose(fp);
    return count;
}

int main(void) {
    const char *filename = "/tmp/demo_output.txt";
    const char *content =
        "Line one: Hello from C.\n"
        "Line two: File I/O is straightforward.\n"
        "Line three: Always close your files.\n"
        "Line four: Check return values.\n"
        "Line five: End of demo.\n";

    printf("Writing to %s...\n", filename);
    if (write_file(filename, content) != 0) return 1;

    printf("Reading back:\n\n");
    read_file(filename);

    int lines = count_lines(filename);
    printf("\nTotal lines: %d\n", lines);

    return 0;
}
