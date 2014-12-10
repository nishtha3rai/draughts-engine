#include <stdio.h>
#include "move_generation.c"
#include "evaluation.c"

#define MAX_DEPTH_AB 7
#define INF 100000

struct checkers_t {
	struct position pos;
	int iter;
	int scr;
	int beta;
	int alpha;
};

/*CREATION OF NEW NODE FOR STACK*/
void new_node(struct position pos, struct checkers_t *leaf_node)
{
	leaf_node->pos = pos;
	leaf_node->iter = 0;
	leaf_node->beta = INF;
	leaf_node->alpha = -INF;
	leaf_node->scr = 0;
}

/*TREE TRAVERSAL*/
int stack_alpha_beta(struct position pos, int turn, char best_mv[32])
{
	char child[MAX_DEPTH_AB][6400];
	char max_depth_reached;
	int best_score;
	int alpha;
	int beta;
	int ply;
	struct checkers_t root;
	struct checkers_t curr_node;
	struct checkers_t prev_node;
	struct checkers_t temp_node;
	struct checkers_t leaf_node;
	struct checkers_t glb_stk[MAX_DEPTH_AB + 1];

	ply = 0;
	alpha = -INF;
	beta = INF;
	best_score = -INF;

	new_node(pos, &root);
	glb_stk[ply] = root;
	ply++;

	if (MAX_DEPTH_AB == 0) {
		if (root.pos.nc == 0) {
			best_score = -INF;
		} else {
			best_score = evaluate(root.pos.board, (turn + 1) % 2);

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
				new_turn = (ply + turn + 1) % 2;
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
					best_score = alpha;
				} else {
					temp_node = glb_stk[ply-1];
					temp_node.scr = curr_node.beta;	       
					glb_stk[ply-1] = temp_node;
				}
			} else {
				curr_node.alpha = alpha;
				glb_stk[ply-1] = curr_node;
				if (ply == 1 && best_score < alpha) {
					int i;
					for (i = 0; i < 32; i++) {
						best_mv[i] = prev_node.pos.board[i];
					}
					best_score = alpha;
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
	return best_score;
}

void print_result(struct position pos, int scr, char best_mv[32])
{
	int i;
	int j;
	printf("pos : ");

	for (i = 0; i < 32; i++) {
		printf("%c", pos.board[i]);
	}
	printf("\nnc  : %d\n", pos.nc);
	printf("children : \n");
	for (i = 0; i < pos.nc; i++) {
		int k = i * 32;
		printf("      ");
		for (j = k; j < k + 32; j++) {
			printf("%c", pos.child_ptr[j]);
		}
		printf("\n");
	}
	printf("best_scr : %d\n", scr);
	printf("best_move : ");
	for (i = 0; i < 32; i++) {
		printf("%c", best_mv[i]);
	}
	printf("\n");

}

