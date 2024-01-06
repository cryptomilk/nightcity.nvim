#include <stdint.h>
#include <stdio.h>

struct foobar {
  uint8_t wurst;
  void *ptr;
};
enum scope {
    FILE_SCOPE1,
    FILE_SCOPE2
};

extern int globalScope; /* @lsp.typemod.variable.globalScope */
static enum scope fileScope; /* @lsp.typemod.variable.fileScope */

void wurst(struct foobar *parameter) {
  int functionScope = 3; /* @lsp.typemod.variable.functionScop, @variable */
  const char *wurst = "brot";

  globalScope = 42;
  fileScope = 32;

  /* NOTE this is bug #123 */
  functionScope = 0.1;

  /* TODO */
  switch (fileScope) {
  case FILE_SCOPE1:
    break;
  default:
    return 5;
  }

  parameter->ptr = NULL;

/* clangd marks unused code as comment */
#if 0
  /* TODO FIXME XXX wurst */

  str = "This is commented out"
#endif

  return;
}

int main(int argc, char *argv[]) {
  struct foobar s = {
      .wurst = '0',
  };
  static int64_t x; /* @lsp.typemod.variable.static */

  wurst(&s);

  return 0;
}
