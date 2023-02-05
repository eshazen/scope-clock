
typedef struct {
  int draw;			/* 0 for move, >0 for draw */
  double x, y;			/* coordinates -1...+1 */
} a_point;

int text2vec( char* s, a_point *list, double scale, double x0, double y0);

// maximum coordinate in the hershey simplex font
#define HERSHEY_MAX 24.0

