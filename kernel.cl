#define N 8
#define WPAWN 'g'
#define WKING 'G'
#define BPAWN 'b'
#define BKING 'B'
#define INF 100000
#define MAX_DEPTH_AB 7

#ifndef MAX_JUMPS
#define MAX_JUMPS 10
#endif

#define STK_SIZE (MAX_JUMPS + 1)

struct position {
	char board[32];
	int nc;
	char *child_ptr;
};

struct checkers_t {
	struct position pos;
	int iter;
	int scr;
	int beta;
	int alpha;
};

struct board_position {
	char board[8][8];
};

struct node {
	struct board_position pos;
	int k;
	int l;
	int nc;
	int it;
	char child[4];
};

int leftUp(char pos[][N], int i, int j) 
{
	if (pos[i][j] == BPAWN || i <= 0 || j <= 0) {
		return 0;
	}

	if (pos[i - 1][j - 1] == '-') {
		pos[i - 1][j - 1] = pos[i][j];
		pos[i][j] = '-';
		if (pos[i - 1][j - 1] == WPAWN && i - 1 == 0) {
			pos[i - 1][j - 1] = WKING;
		}
							
		return 1;
	}
	
	return 0;
}

int rightUp(char pos[][N], int i, int j) 
{
	if (pos[i][j] == BPAWN || i <= 0 || j >= N - 1) {
		return 0;
	}
	if (pos[i - 1][j + 1] == '-') {
		pos[i - 1][j + 1] = pos[i][j];
		pos[i][j] = '-';	
		if (pos[i - 1][j + 1] == WPAWN && i - 1 == 0) {
			pos[i - 1][j + 1] = WKING;
		}

		return 1;
	}
	
	return 0;
}

int leftDown(char pos[][N], int i, int j) 
{
	if (pos[i][j] == WPAWN || i >= N - 1 || j <= 0) {
		return 0;
	}
	if (pos[i + 1][j - 1] == '-') {
		pos[i + 1][j - 1] = pos[i][j];
		pos[i][j] = '-';
		if (pos[i + 1][j - 1] == BPAWN && i + 1 == N - 1) {
			pos[i + 1][j - 1] = BKING;
		}

		return 1;
	}

	return 0;
}

int rightDown(char pos[][N], int i, int j) 
{
	if (pos[i][j] == WPAWN || i >= N - 1 || j >= N - 1) {
		return 0;
	}
	if (pos[i + 1][j + 1] == '-') {
		pos[i + 1][j + 1] = pos[i][j];
		pos[i][j] = '-';
		if (pos[i + 1][j + 1] == BPAWN && i + 1 == N - 1) {
			pos[i + 1][j + 1] = BKING;
		}

		return 1;
	}

	return 0;
}

int leftJumpUp(char pos[][N], int turn, int index[2]) 
{
	int flag;
	int i = index[0];
	int j = index[1];

	if (i <= 1 || j <= 1) {
		return 0;
	}

	flag = 0;
	if (turn) {
		if ((pos[i - 1][j - 1] == WPAWN || pos[i - 1][j - 1] == WKING) && pos[i - 2][j - 2] == '-') {
			flag = 1;
		}
	} else {
		if ((pos[i - 1][j - 1] == BPAWN || pos[i - 1][j - 1] == BKING) && pos[i - 2][j - 2] == '-') {
			flag = 1;
		}
	}
	if (flag) {
		pos[i - 2][j - 2] = pos[i][j];
		if (!turn) {
			if (pos[i - 2][j - 2] == WPAWN && i - 2 == 0) {
				pos[i - 2][j - 2] = WKING;
			}
		}
		pos[i - 1][j - 1] = '-';
		pos[i][j] = '-';
		index[0] = i - 2;
		index[1] = j - 2;

		return 1;
	}	

	return 0;
}

int rightJumpUp(char pos[][N], int turn, int index[2]) 
{
	int flag;
	int i = index[0];
	int j = index[1];

	if (i <= 1 || j >= N - 2) {
		return 0;
	}

	flag = 0;
	if (turn) {
		if (((pos[i - 1][j + 1] == WPAWN) || (pos[i - 1][j + 1] == WKING)) && pos[i - 2][j + 2] == '-') {
			flag = 1;
		}
	} else {
		if (((pos[i - 1][j + 1] == BPAWN) || (pos[i - 1][j + 1] == BKING)) && pos[i - 2][j + 2] == '-') {
			flag = 1;
		}
	}
	if (flag) {
		pos[i - 2][j + 2] = pos[i][j];
		if (!turn) {
			if (pos[i - 2][j + 2] == WPAWN && i - 2 == 0) {
				pos[i - 2][j + 2] = WKING;
			}
		}
		pos[i - 1][j + 1] = '-';
		pos[i][j] = '-';
		index[0] = i - 2;
		index[1] = j + 2;

		return 1;
	}	

	return 0;
}

int leftJumpDown(char pos[][N], int turn, int index[2]) 
{
	int flag;
	int i = index[0];
	int j = index[1];

	if (i >= N - 2 || j <= 1) {
		return 0;
	}

	flag = 0;
	if (turn) {
		if (((pos[i + 1][j - 1] == WPAWN) || (pos[i + 1][j - 1] == WKING)) && pos[i + 2][j - 2] == '-') {
			flag = 1;
		}
	} else {
		if (((pos[i + 1][j - 1] == BPAWN) || (pos[i + 1][j - 1] == BKING)) && pos[i + 2][j - 2] == '-') {
			flag = 1;
		}
	 }
	if (flag) {
		pos[i + 2][j - 2] = pos[i][j];
		if (turn) {
			if (pos[i + 2][j - 2] == BPAWN && i + 2 == N - 1) {
				pos[i + 2][j - 2] = BKING;
			}
		}
		pos[i + 1][j - 1] = '-';
		pos[i][j] = '-';
		index[0] = i + 2;
		index[1] = j - 2;

		return 1;
	}

	return 0;
}

int rightJumpDown(char pos[][N], int turn, int index[2]) 
{
	int flag;
	int i = index[0];
	int j = index[1];

	if (i >= N - 2 || j >= N - 2) {
		return 0;
	}

	flag = 0;
	if (turn) {
		if ((pos[i + 1][j + 1] == WPAWN || pos[i + 1][j + 1] == WKING) && pos[i + 2][j + 2] == '-') {
			flag = 1;
		}
	} else {
		if ((pos[i + 1][j + 1] == BPAWN || pos[i + 1][j + 1] == BKING) && pos[i + 2][j + 2] == '-') {
			flag = 1;	
		}
	}
	if (flag) {
		pos[i + 2][j + 2] = pos[i][j];
		if (turn) {
			if (pos[i + 2][j + 2] == BPAWN && i + 2 == N - 1) {
				pos[i + 2][j + 2] = BKING;
			}
		}
		pos[i + 1][j + 1] = '-';
		pos[i][j] = '-';
		index[0] = i + 2;
		index[1] = j + 2;	

		return 1;
	}

	return 0;
}

void convert_into_2D(char a[32], char b[][N])
{
	int i;
	int j;
	int k;

	k = 0;
	for (i = 0; i < N; i++) {
		for (j = 0; j < N; j++) {
			if ((i % 2 == 0 && j % 2 == 0) || (i % 2 != 0 && j % 2 != 0)) {
				b[i][j] = '-';
			} else {
				b[i][j] = a[k++];
			}
		}
	}
}

void convert_into_1D(char a[][N], char b[32])
{
	int i;
	int j;
	int k;

	k = 0;
	for (i = 0; i < N; i++) {
		for (j = 0; j < N; j++) {
			if ((i % 2 == 0 && j % 2 != 0) || (i % 2 != 0 && j % 2 == 0)) {
				b[k++] = a[i][j];
			}
		}
	}
}

void insert_into_array(struct board_position pos, int nc, char *child_ptr)
{
	char child[32];
	int x;
	int y;

	convert_into_1D(pos.board, child);

	y = 0;
	for (x = nc * 32; x < (nc * 32) + 32; x++) {
		*(child_ptr + x) = child[y++];
	}
}

void init_new_node(struct board_position pos, int k, int l, struct node *leaf)
{
	leaf->pos = pos;
	leaf->k = k;
	leaf->l = l;
	leaf->nc = 4;
	leaf->it = 0;
	leaf->child[0] = '0';
	leaf->child[1] = '1';
	leaf->child[2] = '2';
	leaf->child[3] = '3';
}

int stacks(struct board_position pos, int k, int l, int turn, int *nc, char *child_ptr)
{
	struct node root;
	struct node leaf;
	struct node ply_node;
	struct node stk[STK_SIZE];

	struct board_position p;
	int i;
	int j;
	int v = -1;
	int flag;
	int ply = -1;
	int jump_flag = 0;

	init_new_node(pos, k, l, &root);
	ply++;
	stk[ply] = root;
	
	while (ply != -1) {
		if (ply < MAX_JUMPS) {
			ply_node = stk[ply];
			
			if (ply_node.it < ply_node.nc) {
				int index[2];
				
				ply_node.it++;
				
				flag = 0;
				index[0] = ply_node.k;
				index[1] = ply_node.l;
				i = index[0];
				j = index[1];
				v = ply_node.child[ply_node.it - 1];
				p = ply_node.pos;
					
				if (v == '0' && p.board[i][j] != WPAWN) {
					if (p.board[i][j] != WKING || i != 0 || ply <= 0) {				
						flag = leftJumpDown(p.board, turn, index);
					}
				} else if (v == '1' && p.board[i][j] != WPAWN) {
					if (p.board[i][j] != WKING || i != 0 || ply <= 0) {	
						flag = rightJumpDown(p.board, turn, index);
					}
				} else if (v == '2' && p.board[i][j] != BPAWN) {
					if (p.board[i][j] != BKING || i != N - 1 || ply <= 0) {	
						flag = leftJumpUp(p.board, turn, index);
					}
				} else if (v == '3' && p.board[i][j] != BPAWN) {
					if (p.board[i][j] != BKING || i != N - 1 || ply <= 0) {
						flag = rightJumpUp(p.board, turn, index);
					}
				}

				if (flag) {
					init_new_node(p, index[0], index[1], &leaf);
					
					insert_into_array(p, *nc, child_ptr);
					(*nc)++;
					jump_flag = 1;

					stk[ply] = ply_node;
					ply++;
					stk[ply] = leaf;
				} else {
					stk[ply] = ply_node;
				}
			} else {
				ply--;
			}
		} else {
			ply--;
			ply_node = stk[ply];
		}
	}

	return jump_flag;
}

void individualMove(struct board_position pos, int i, int j, int turn, int *nc, char *child_ptr) 
{
	struct board_position p;

	if (pos.board[i][j] != WPAWN) {
		p = pos;
		if (leftDown(p.board, i, j)) {
			insert_into_array(p, *nc, child_ptr);
			(*nc)++;
		}
		p = pos;
		if (rightDown(p.board, i, j)) {
			insert_into_array(p, *nc, child_ptr);
			(*nc)++;
		}
	}

	if (pos.board[i][j] != BPAWN) {
		p = pos;
		if (leftUp(p.board, i, j)) {
			insert_into_array(p, *nc, child_ptr);
			(*nc)++;
		}
		p = pos;
		if (rightUp(p.board, i, j)) {
			insert_into_array(p, *nc, child_ptr);
			(*nc)++;
		}
	}
}

void generate_moves(char board[32], int turn, int *nc, char *child_ptr)
{
	int flag;
	int i;
	int j;
	char p[N][N];
	struct board_position pos;

	convert_into_2D(board, p);
	flag = 1;

	for (i = 0; i < N; i++) {
		for (j = 0; j < N; j++) {
			if (turn && flag) {
				if (p[i][j] == BPAWN || p[i][j] == BKING) {
					flag = 0;
				}
			} else if (flag) {
				if (p[i][j] == WPAWN || p[i][j] == WKING) {
					flag = 0;
				}
			}
			pos.board[i][j] = p[i][j];
		}
	}

	if (flag) {
		return;
	}

	flag = 0;

	for (i = 0; i < N; i++) {
		for (j = 0; j < N; j++) {
			if (turn) {
				if (pos.board[i][j] == BPAWN || pos.board[i][j] == BKING) {
					if (stacks(pos, i, j, turn, nc, child_ptr)) {
						flag = 1;
					}
				}
			} else {
				if (pos.board[i][j] == WPAWN || pos.board[i][j] == WKING) {			
					if (stacks(pos, i, j, turn, nc, child_ptr)) {
						flag = 1;
					}
				}
			}
		}
	}

	if (!flag) {
		for (i = 0; i < N; i++) {
			for (j = 0; j < N; j++) {
				if (turn) {
					if (pos.board[i][j] == BPAWN || pos.board[i][j] == BKING) {
						individualMove(pos, i, j, turn, nc, child_ptr);
					}
				} else {
					if (pos.board[i][j] == WPAWN || pos.board[i][j] == WKING) {				
						individualMove(pos, i, j, turn, nc, child_ptr);
					}
				}
			}
		}
	}
}

void init_new_child(struct position pos, struct position *new_pos, int turn, int i)  
{
	int j;

	new_pos->nc = 0;

	for (j = 0; j < 32; j++) {
		new_pos->board[j] = pos.child_ptr[(i * 32) + j];
	}

	generate_moves(new_pos->board, (turn + 1) % 2, &(new_pos->nc), new_pos->child_ptr);
}

int safe_pieces(char pos[32], int turn)
{
	int count;
	int i;

	count = 0;

	if (turn == 1) {
		for (i = 4; i < 29; i = i + 8) {
			if (pos[i] == 'b') {
				count = count + 100;
			} else if (pos[i] == 'B') {
				count = count + 200;
			}
		}
		for (i = 3; i < 28; i = i + 8) {
			if (pos[i] == 'b') {
				count = count + 100;
			} else if (pos[i] == 'B') {
				count = count + 200;
			}
		}
	} else if (turn == 0) {
		for (i = 4; i < 29; i = i + 8) {
			if (pos[i] == 'g') {
				count = count + 100;
			} else if (pos[i] == 'G') {
				count = count + 200;
			}
		}
		for (i = 3; i < 28; i = i + 8) {
			if (pos[i] == 'g') {
				count = count + 100;
			} else if (pos[i] == 'G') {
				count = count + 200;
			}
		}
	}

	return count;
}

int defender_pieces(char pos[32], int turn)
{
	int count;
	int i;

	count = 0;

	if (turn == 1) {
		for (i = 0; i < 8; i++) {
			if (pos[i] == 'b') {
				count = count + 100;
			} else if (pos[i] == 'B') {
				count = count + 200;
			}
		}
	} else if (turn == 0) {
		for (i = 24; i < 32; i++) {
			if (pos[i] == 'g') {
				count = count + 100;
			} else if (pos[i] == 'G') {
				count = count + 200;
			}
		}
	}

	return count;
}

int loner_pieces(char pos[32], int turn)
{
	int count;
	int i;

	count = 0;

	if (turn == 1) {
		for (i = 0; i < 32; i++) {
			if (pos[i] == 'b' || pos[i] == 'B') {
				if (i < 4) {
					if (i == 0) {
						if ((pos[5] == '-') && (pos[4] == '-')) {
							count++;
						}
					} else if (i == 3) {
						if (pos[7] == '-') {
							count++;
						}
					} else {
						if ((pos[i+4] == '-') && (pos[i+5] == '-')) {
							count++;
						}
					}
				} else if (i >= 4 && i < 28) {
					if (i == 4 || i == 12 || i == 20 || i == 11 || i == 19 || i == 27) {
						if ((pos[i-4] == '-') && (pos[i+4] == '-')) {
							count++;
						}
					} else {
						if ((i >= 5 && i < 8) || (i >= 13 && i < 16) || (i >= 21 && i < 24)) {
							if ((pos[i-5] == '-') && (pos[i-4] == '-') &&
							    (pos[i+3] == '-') && (pos[i+4] == '-')) {
								count++;
							}
						} else {
							if ((pos[i-3] == '-') && (pos[i-4] == '-') &&
							    (pos[i+5] == '-') && (pos[i+4] == '-')) {
								count++;
							}
						}
					}
				} else if (i >= 28 && i < 32) {
					if (i == 28) {
						if (pos[24] == '-') {
							count++;
						}
					} else if (i == 31) {
						if ((pos[26] == '-') && (pos[27] == '-')) {
							count++;
						}
					} else {
						if ((pos[i-5] == '-') && (pos[i-4] == '-')) {
							count++;
						}
					}
				}
			}
		}
	} else if (turn == 0) {
		for (i = 0; i < 32; i++) {
			if (pos[i] == 'g' || pos[i] == 'G') {
				if (i < 4) {
					if (i == 0) {
						if ((pos[5] == '-') && (pos[4] == '-')) {
							count++;
						}
					} else if (i == 3) {
						if (pos[7] == '-') {
							count++;
						}
					} else {
						if ((pos[i+4] == '-') && (pos[i+5] == '-')) {
							count++;
						}
					}
				} else if (i >= 4 && i < 28) {
					if (i == 4 || i == 12 || i == 20 || i == 11 || i == 19 || i == 27) {
						if ((pos[i-4] == '-') && (pos[i+4] == '-')) {
							count++;
						}
					} else {
						if ((i >= 5 && i < 8) || (i >= 13 && i < 16) || (i >= 21 && i < 24)) {
							if ((pos[i-5] == '-') && (pos[i-4] == '-') &&
							    (pos[i+3] == '-') && (pos[i+4] == '-')) {
								count++;
							}
						} else {
							if ((pos[i-3] == '-') && (pos[i-4] == '-') &&
							    (pos[i+5] == '-') && (pos[i+4] == '-')) {
								count++;
							}
						}
					}
				} else if (i >= 28 && i < 32) {
					if (i == 28) {
						if (pos[24] == '-') {
							count++;
						}
					} else if (i == 31) {
						if ((pos[26] == '-') && (pos[27] == '-')) {
							count++;
						}
					} else {
						if ((pos[i-5] == '-') && (pos[i-4] == '-')) {
							count++;
						}
					}
				}
			}
		}
	}

	return count;
	
}

int attacking_pieces(char pos[32], int turn)
{
	int count;
	int i;

	count = 0;

	if (turn == 1) {
		for (i = 20; i < 32; i++) {
			if (pos[i] == 'b') {
				count = count + 100;
			} else if (pos[i] == 'B') {
				count = count + 200;
			}
		}
	} else if (turn == 0) {
		for (i = 0; i < 12; i++) {
			if (pos[i] == 'g') {
				count = count + 100;
			} else if (pos[i] == 'G') {
				count = count + 200;
			}
		}
	}

	return count;
}

int kill_left_up(char pos[8][8], char ch, int i, int j)
{
	if (ch == 'b') {
		return 0;
	}

	if (i < 2 || j < 2) {
		return 0;
	}

	if (ch == 'B') {
		if ((pos[i-1][j-1] == 'g' || pos[i-1][j-1] == 'G') && (pos[i-2][j-2] == '-')) {
			return 1;
		}
	} else if (ch == 'g' || ch == 'G') {
		if ((pos[i-1][j-1] == 'b' || pos[i-1][j-1] == 'B') && (pos[i-2][j-2] == '-')) {
			return 1;
		}
	}

	return 0;
}

int kill_right_up(char pos[8][8], char ch, int i, int j)
{
	if (ch == 'b') {
		return 0;
	}

	if (i < 2 || j > 5) {
		return 0;
	}

	if (ch == 'B') {
		if ((pos[i-1][j+1] == 'g' || pos[i-1][j+1] == 'G') && (pos[i-2][j+2] == '-')) {
			return 1;
		}
	} else if (ch == 'g' || ch == 'G') {
		if ((pos[i-1][j+1] == 'b' || pos[i-1][j+1] == 'B') && (pos[i-2][j+2] == '-')) {
			return 1;
		}
	}

	return 0;
}

int kill_left_down(char pos[8][8], char ch, int i, int j)
{
	if (ch == 'g') {
		return 0;
	}

	if (i > 5 || j < 2) {
		return 0;
	}

	if (ch == 'b' || ch == 'B') {
		if ((pos[i+1][j-1] == 'g' || pos[i+1][j-1] == 'G') && (pos[i+2][j-2] == '-')) {
			return 1;
		}
	} else if (ch == 'G') {
		if ((pos[i+1][j-1] == 'b' || pos[i+1][j-1] == 'B') && (pos[i+2][j-2] == '-')) {
			return 1;
		}
	}

	return 0;
}

int kill_right_down(char pos[8][8], char ch, int i, int j)
{
	if (ch == 'g') {
		return 0;
	}

	if (i > 5 || j > 5) {
		return 0;
	}

	if (ch == 'b' || ch == 'B') {
		if ((pos[i+1][j+1] == 'g' || pos[i+1][j+1] == 'G') && (pos[i+2][j+2] == '-')) {
			return 1;
		}
	} else if (ch == 'G') {
		if ((pos[i+1][j+1] == 'b' || pos[i+1][j+1] == 'B') && (pos[i+2][j+2] == '-')) {
			return 1;
		}
	}

	return 0;
}

int killer_pieces(char posi[32], int turn)
{
	char pos[8][8];
	char ch;
	int count;
	int i;
	int j;
	int k;

	k = 0;
	
	for (i = 0; i < 8; i++) {
		for (j = 0; j < 8; j++) {
			if ((i % 2 == 0 && j % 2 == 0) || (i % 2 != 0 && j % 2 != 0)) {
				pos[i][j] = '-';
			} else {
				pos[i][j] = posi[k++];
			}
		}
	}
	count = 0;

	if (turn == 1) {
		for (i = 0; i < 8; i++) {
			for (j = 0; j < 8; j++) {
				if (pos[i][j] == 'b' || pos[i][j] == 'B') {
					ch = pos[i][j];

					if (kill_left_up(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_right_up(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_left_down(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_right_down(pos, ch, i, j) == 1) {
						count++;
					}
				}
			}
		}
	} else if (turn == 0) {
		for (i = 0; i < 8; i++) {
			for (j = 0; j < 8; j++) {
				if (pos[i][j] == 'g' || pos[i][j] == 'G') {
					ch = pos[i][j];

					if (kill_left_up(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_right_up(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_left_down(pos, ch, i, j) == 1) {
						count++;
					}
					if (kill_right_down(pos, ch, i, j) == 1) {
						count++;
					}
				}
			}
		}
	}

	return count;
}

int evaluate(char pos[32], int turn)
{
	int safe;          		 
	int loner;             		  
	int defender;         		  
	int attacking;        		  
	int killer;        		  
	int score;

	safe = safe_pieces(pos, turn);
	loner = loner_pieces(pos, turn) * 100;
	defender = defender_pieces(pos, turn);
	attacking = attacking_pieces(pos, turn);
	killer = killer_pieces(pos, turn) * 100;

	score = safe + loner + defender + attacking + killer;

	return score;
}

void new_node(struct position pos, struct checkers_t *leaf_node)
{
	leaf_node->pos = pos;
	leaf_node->iter = 0;
	leaf_node->beta = INF;
	leaf_node->alpha = -INF;
	leaf_node->scr = 0;
}

__kernel void stack_ab( __global char board[32],
			__global int *nc, 
			__global char *child_ptr,
			__global int *turn, 
			__global char best_mv[32], 
			__global int *best_score )
{	
	struct position pos;
	char pos_child[6400];
	char child[MAX_DEPTH_AB][6400];
	char max_depth_reached;
	int alpha;
	int beta;
	int ply;
	int i;
	struct checkers_t root;
	struct checkers_t curr_node;
	struct checkers_t prev_node;
	struct checkers_t temp_node;
	struct checkers_t leaf_node;
	struct checkers_t glb_stk[MAX_DEPTH_AB + 1];

	for (i = 0;i < 32; i++) {
		pos.board[i] = board[i];
	}
	pos.nc = 0;
	pos.child_ptr = pos_child;
	
	generate_moves(pos.board, *turn, &(pos.nc), pos.child_ptr);
	
	for (i = 0; i < (32 * pos.nc); i++) {
		child_ptr[i] = pos_child[i];
	}
	*nc = pos.nc;
	ply = 0;
	alpha = -INF;
	beta = INF;
	*best_score = -INF;

	new_node(pos, &root);
	glb_stk[ply] = root;
	ply++;
	
	if (MAX_DEPTH_AB == 0) {
		if (root.pos.nc == 0) {
			*best_score = -INF;
		} else {
			*best_score = evaluate(root.pos.board, (*turn + 1) % 2);
		}
	}

	while (ply > 0) {
		max_depth_reached = 1;
		if (ply < MAX_DEPTH_AB + 1) {
			curr_node = glb_stk[ply-1];
			max_depth_reached = 0;
			if (curr_node.iter < curr_node.pos.nc) {
				struct position p;
				int new_turn;
				
				p.child_ptr = child[ply - 1];
				curr_node.iter++;
				new_turn = (ply + *turn + 1) % 2;
				init_new_child(curr_node.pos, &p, new_turn, curr_node.iter - 1);
				new_node(p, &leaf_node);
				
				if (leaf_node.pos.nc == 0) {
					if (ply % 2 == 0) {
						leaf_node.scr = -INF;					
					} else {
						leaf_node.scr = INF;					
					}
				} else if (ply == MAX_DEPTH_AB) {
					leaf_node.scr = evaluate(p.board, new_turn);
				} else {
					leaf_node.alpha = curr_node.alpha;
					leaf_node.beta = curr_node.beta;
					if (ply % 2 != 0) {						
						leaf_node.scr = -INF;					
					} else {							
						leaf_node.scr = INF;					
					}
				}

				if (ply % 2 != 0) {
					curr_node.scr = (curr_node.scr > leaf_node.scr) ? curr_node.scr : leaf_node.scr;
				} else {
					curr_node.scr = (curr_node.scr < leaf_node.scr) ? curr_node.scr : leaf_node.scr;
				}
						
				glb_stk[ply-1] = curr_node;
				ply++;
				glb_stk[ply-1] = leaf_node;
				
				continue;
			}
		}
		prev_node = glb_stk[ply-1];
		ply--;
		if (ply <= 0) {
			continue;
		}
		curr_node = glb_stk[ply-1];
		
		if (ply % 2 == 1) {
			if (max_depth_reached) {  	
				alpha = (prev_node.scr > curr_node.alpha) ? prev_node.scr : curr_node.alpha;
			} else {  			
				alpha = (prev_node.scr < curr_node.beta) ? prev_node.scr : curr_node.beta;
			}
			curr_node.scr = alpha;
			if (alpha >= curr_node.beta) {
				ply--;

				if (ply == 0) {
					*best_score = alpha;
				} else {
					temp_node = glb_stk[ply-1];
					temp_node.scr = curr_node.beta;	       
					glb_stk[ply-1] = temp_node;
				}
			} else {
				curr_node.alpha = alpha;
				glb_stk[ply-1] = curr_node;
				if (ply == 1 && *best_score < alpha) {
					int i;
					for (i = 0; i < 32; i++) {
						best_mv[i] = prev_node.pos.board[i];
					}
					*best_score = alpha;
				}
			}
		} else {
			if (max_depth_reached) {
				beta = (prev_node.scr < curr_node.beta) ? prev_node.scr : curr_node.beta;
			} else { 				
				beta = (prev_node.scr > curr_node.alpha) ? prev_node.scr : curr_node.alpha;
			}
			curr_node.scr = beta;
			if (curr_node.alpha >= beta) {
				ply--;
				temp_node = glb_stk[ply-1];
				temp_node.scr = curr_node.alpha;  
				glb_stk[ply-1] = temp_node;            
			} else {
				curr_node.beta = beta;
				glb_stk[ply-1] = curr_node;
			}
		}
	}
}

