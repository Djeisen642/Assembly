#include <stdio.h>
#include <stdlib.h>

void quick_sort (int *a, int n) {
    if (n < 2) //if it's less than 2, stop sorting
        return;
    int p = a[n / 2]; //choose the middle as a pivot
    int *l = a; //left = first one
    int *r = a + n - 1; //right = left one
    while (l <= r) {    //while left is less than or equal to right
        while (*l < p) // while left is less than the pivot
            l++;    //move left right
        while (*r > p)  //while right is greater than pivot
            r--;    //move right left
        if (l <= r) { //if left is less than or equal to right
            int t = *l; //store left in t
            *l++ = *r;  //move right to left
            *r-- = t;   //move left to right
        }
    }
    quick_sort(a, r - a + 1); //sort the first half
    quick_sort(l, a + n - l); //sort the second half
}
 
int main () {
    int a[] = {4, 65, 2, -31, 0, 99, 2, 83, 782, 1};
    int n = sizeof a / sizeof a[0];
    quick_sort(a, n);
    for (int i = 0; i < n; i++ ) {
        printf("%d ", a[i]);
    }
    printf("\n");
    return 0;
}