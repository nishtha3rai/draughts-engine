#include <stdio.h>
#include "stack_ab.c"

int main()
{
	int i;
	int nc;
	int scr;
	int turn;
	char best_mv[32];
	char child_ptr[6400];
	char arr[32];
	struct position pos;

	nc = 0;

	for (i = 0; i < 32; i++) {
		scanf("%c ", &arr[i]);
	}

	scanf("%d", &turn);
	generate_moves(arr, turn, &nc, child_ptr);

	for (i = 0; i < 32; i++) {
		best_mv[i] = '-';
		pos.board[i] = arr[i];
	}

	pos.nc = nc;
	pos.child_ptr = child_ptr;

	scr = stack_alpha_beta(pos, turn, best_mv);

	print_result(pos, scr, best_mv);

	return 0;
}

