#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>
#include <stdint.h>

int main() {

  int64_t all31 = 0x7fffffff;
  int64_t all63 = 0x7fffffffffffffff;
  int64_t product = all31 * all31;
  int64_t difference = all63 - product;
  printf("all31, all63, product, difference: %lld %lld, %lld\n", all31, all63, product, difference);

  uint64_t all32 = 0xffffffff;
  uint64_t all64 = 0xffffffffffffffff;
  uint64_t uproduct = all32 * all32;
  uint64_t udifference = all64 - uproduct;
  printf("all32, all64, uproduct, udifference: %llu %llu, %llu\n", all32, all64, uproduct, udifference);

  return 0;
}
