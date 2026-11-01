#!/usr/bin/env bash
# Prints the "HYPERGAMY" diagram in the terminal (ANSI colors, needs awk).

awk '
function put(r, c, ch, col) { g[r, c] = ch; k[r, c] = col }
function line(x0, y0, x1, y1, col, head,   x, y, step, n, i, py, ch) {
  step = (x1 >= x0) ? 1 : -1
  n = (x1 - x0) * step
  py = y0
  for (i = 0; i <= n; i++) {
    x = x0 + i * step
    y = int(y0 + (y1 - y0) * i / n + ((y1 - y0) >= 0 ? 0.5 : -0.5))
    if (i == n)            ch = head
    else if (y == py)      ch = "-"
    else if (y > py)       ch = "\\"
    else                   ch = "/"
    put(y, x, ch, col)
    py = y
  }
}
function text(r, c, s, col,   i) { for (i = 1; i <= length(s); i++) put(r, c + i - 1, substr(s, i, 1), col) }

BEGIN {
  RED = 1; CYAN = 2; WHITE = 3; DIM = 4
  R = 20; W = 80; N = 10
  OFF = 42

  for (i = 0; i < N; i++) {
    r = 2 * i
    # left panel: men (red) -> women
    text(r, 0, "[M]", RED);   text(r, 33, "(F)", WHITE)
    # right panel: men -> women (cyan)
    text(r, OFF, "[M]", WHITE); text(r, OFF + 33, "(F)", CYAN)
  }

  # left: every man is happy with several women
  for (i = 0; i < N; i++) {
    for (d = -2; d <= 2; d++) {
      j = i + d
      if (j < 0 || j >= N) continue
      if (d == 0 || d == -1 || d == 1 || (d == 2 && i % 2 == 0))
        line(4, 2 * i, 30, 2 * j, RED, ">")
    }
  }

  # right: every woman aims at the top three men
  for (j = 0; j < N; j++)
    for (m = 0; m < 3; m++)
      line(OFF + 32, 2 * j, OFF + 4, 2 * m, CYAN, "<")

  # redraw people on top so lines never overwrite them
  for (i = 0; i < N; i++) {
    r = 2 * i
    text(r, 0, "[M]", RED);   text(r, 33, "(F)", WHITE)
    text(r, OFF, "[M]", WHITE); text(r, OFF + 33, "(F)", CYAN)
  }

  esc = sprintf("%c", 27)
  c[RED] = esc "[31m"; c[CYAN] = esc "[36m"; c[WHITE] = esc "[97m"; c[DIM] = esc "[2m"
  rst = esc "[0m"; bold = esc "[1m"

  printf "\n%*s%s%s%s\n", 33, "", bold, "H Y P E R G A M Y", rst
  s = ""; for (i = 0; i < W; i++) s = s "="; print s
  printf "\n%s%s%s%s%s%s%s\n\n", c[DIM], "   WHOM MEN WOULD HAPPILY PARTNER WITH", "          ", "   WHOM WOMEN WOULD HAPPILY PARTNER WITH", rst, "", ""

  for (r = 0; r <= R - 2; r++) {
    out = ""; cur = 0
    for (cc = 0; cc < W; cc++) {
      if ((r, cc) in g) {
        if (k[r, cc] != cur) { out = out c[k[r, cc]]; cur = k[r, cc] }
        out = out g[r, cc]
      } else {
        if (cur != 0) { out = out rst; cur = 0 }
        out = out " "
      }
    }
    print out rst
  }

  print ""
  printf "%s%*s%s\n", c[DIM], 14, "Anything above the expectation arrow would be considered a catch,", rst
  printf "%s%*s%s\n\n", c[DIM], 28, "anything below would be settling", rst
}'
