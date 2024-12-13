#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct rule {
    int v1;
    int v2;
} t_rule; 

typedef struct page {
    int *nums;
    int count;
} t_page;

int read_file(char *file_path, t_rule **rules, t_page **pages, size_t *rule_count, size_t *page_count) {
    FILE *file = fopen(file_path, "r");
    if (!file) {
        perror("Failed to open file");
        return 1;
    }

    *rule_count = 0;
    int v1 = 0, v2 = 0;
    while (2 == fscanf(file, "%d|%d", &v1, &v2)) {
       (*rule_count)++;
    }

    *rules = (t_rule *)malloc(*(rule_count) * sizeof(t_rule));

    rewind(file);
    long rule_idx = 0;
    char c, tmp;
    while (2 == fscanf(file, "%d|%d", &v1, &v2)) {
        (*rules)[rule_idx++] = (t_rule){ .v1 = v1, .v2 = v2 };
        tmp = c;
        c = fgetc(file);
        if ('\n' == c) {
            c = fgetc(file);
            if (!isdigit(c)) {
                break;
            }
        }
        ungetc(c, file);
    }

    *page_count = 0;
    char *line = NULL;
    size_t line_size = 0;
    *pages = NULL;
    while (-1 != getline(&line, &line_size, file)) {
        line[strcspn(line, "\n")] = 0;
        if (0 == strlen(line)) break; 
        
        int *currPage = NULL;
        int count = 0;

        char *save_ptr;

        char *token = strtok_r(line, ", ", &save_ptr);
        while (NULL != token) {
            currPage = realloc(currPage, (count + 1) * sizeof(int));
            currPage[count++] = atoi(token);
            token = strtok_r(NULL, ", ", &save_ptr);
        }

        *pages = realloc(*pages, (*(page_count) + 1) * sizeof(t_page));

        (*pages)[*(page_count)].nums = malloc(count * sizeof(int));
        memcpy((*pages)[*(page_count)].nums, currPage, count * sizeof(int));
        (*pages)[*(page_count)].count = count;
        (*page_count)++;
    }

    
    fclose(file);
    return 0;
}

int part1(t_rule **rules, t_page **pages, size_t rule_count, size_t page_count) {
    int ret = 0;
    int rulebreak = 0;
    for (size_t i = 0; i < page_count; i++) {
        rulebreak = 0;
        int midIdx = (*pages)[i].count / 2;
        for (size_t j = 0; j < (*pages)[i].count - 1; j++) {
            int current = (*pages)[i].nums[j];
            for (size_t k = j; k < (*pages)[i].count; k++) {
                int comp = (*pages)[i].nums[k];
                for (size_t r = 0; r < rule_count; r++) {
                    if (0 == rulebreak) {
                        if ((*rules)[r].v2 == current && (*rules)[r].v1 == comp){
                            rulebreak = 1;
                        }
                    }
                }
            }
        }
        if (0 == rulebreak) {
            ret += (*pages)[i].nums[midIdx];
        }
    }
    return ret;
}

int part2(t_rule **rules, t_page **pages, size_t rule_count, size_t page_count) {
    int ret = 0;
    
    for (size_t i = 0; i < page_count; i++) {
        int *page_copy = malloc((*pages)[i].count * sizeof(int));
        memcpy(page_copy, (*pages)[i].nums, (*pages)[i].count * sizeof(int));
        
        int sorted = 0;
        int iterations = 0;
        
        while (!sorted && iterations < (*pages)[i].count) {
            sorted = 1;
            
            for (size_t j = 0; j < (*pages)[i].count - 1; j++) {
                for (size_t k = j + 1; k < (*pages)[i].count; k++) {
                    int needs_swap = 0;
                    for (size_t r = 0; r < rule_count; r++) {
                        if ((*rules)[r].v2 == page_copy[j] && 
                            (*rules)[r].v1 == page_copy[k]) {
                            int temp = page_copy[j];
                            page_copy[j] = page_copy[k];
                            page_copy[k] = temp;
                            sorted = 0;
                            needs_swap = 1;
                            break;
                        }
                    }
                    if (needs_swap) break;
                }
            }
            
            iterations++;
        }
        
        int midIdx = (*pages)[i].count / 2;
        ret += page_copy[midIdx];
        
        free(page_copy);
    }
    
    return ret - part1(rules, pages, rule_count, page_count);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    size_t rule_count;
    t_rule *rules;
    size_t page_count;
    t_page *pages;

    if (1 == read_file(argv[1], &rules, &pages, &rule_count, &page_count)) {
        return 1;
    }

    printf("Part 1: %d\n", part1(&rules, &pages, rule_count, page_count));
    printf("Part 2: %d\n", part2(&rules, &pages, rule_count, page_count));
}
