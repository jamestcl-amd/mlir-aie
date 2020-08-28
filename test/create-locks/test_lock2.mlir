// RUN: aie-opt --aie-create-locks %s | FileCheck %s

// CHECK-LABEL: module @test_lock2 {
// CHECK:  %0 = AIE.tile(3, 3)
// CHECK:  %1 = AIE.lock(%0, 0)
// CHECK:  %2 = AIE.tile(2, 3)
// CHECK:  %3 = AIE.lock(%2, 0)
// CHECK:  %4 = AIE.tile(3, 4)
// CHECK:  %5 = AIE.lock(%4, 0)
// CHECK:  %6 = AIE.tile(4, 3)
// CHECK:  %7 = AIE.tile(3, 2)
// CHECK:  %8 = AIE.lock(%7, 0)
// CHECK:  AIE.token(0) {sym_name = "token0"}
// CHECK:  AIE.token(0) {sym_name = "token1"}
// CHECK:  AIE.token(0) {sym_name = "token2"}
// CHECK:  AIE.token(0) {sym_name = "token3"}
// CHECK:  %14 = AIE.core(%2) {
// CHECK:    AIE.useLock(%3, "Acquire", 1, 0)
// CHECK:    AIE.useLock(%3, "Release", 0, 0)
// CHECK:  }
// CHECK:  %15 = AIE.core(%0) {
// CHECK:    AIE.useLock(%8, "Acquire", 0, 0)
// CHECK:    AIE.useLock(%1, "Acquire", 0, 0)
// CHECK:    AIE.useLock(%5, "Acquire", 0, 0)
// CHECK:    AIE.useLock(%3, "Acquire", 0, 0)
// CHECK:    AIE.useLock(%3, "Release", 1, 0)
// CHECK:    AIE.useLock(%5, "Release", 1, 0)
// CHECK:    AIE.useLock(%1, "Release", 1, 0)
// CHECK:    AIE.useLock(%8, "Release", 1, 0)
// CHECK:  }
// CHECK:  %16 = AIE.core(%4) {
// CHECK:    AIE.useLock(%5, "Acquire", 1, 0)
// CHECK:    AIE.useLock(%5, "Release", 0, 0)
// CHECK:  }
// CHECK:  %17 = AIE.core(%6) {
// CHECK:    AIE.useLock(%1, "Acquire", 1, 0)
// CHECK:    AIE.useLock(%1, "Release", 0, 0)
// CHECK:  }
// CHECK:  %18 = AIE.core(%7) {
// CHECK:    AIE.useLock(%8, "Acquire", 1, 0)
// CHECK:    AIE.useLock(%8, "Release", 0, 0)
// CHECK:  }
// CHECK:}

// Generate LockOp in the top-level module
// Lower UseTokenOp to UseLockOp
//      Tile
//       |
// Tile-Tile-Tile
//       |
//      Tile
// single producer (tile(3, 3)), multiple consumers
module @test_lock2 {
  %t33 = AIE.tile(3, 3)
  %t23 = AIE.tile(2, 3)
  %t34 = AIE.tile(3, 4)
  %t43 = AIE.tile(4, 3)
  %t32 = AIE.tile(3, 2)

  AIE.token(0) {sym_name = "token0"}
  AIE.token(0) {sym_name = "token1"}
  AIE.token(0) {sym_name = "token2"}
  AIE.token(0) {sym_name = "token3"}

  %m33 = AIE.mem(%t33) {
    AIE.terminator(^end)
    ^end:
      AIE.end
  }

  %m23 = AIE.mem(%t23) {
    AIE.terminator(^end)
    ^end:
      AIE.end
  }

  %m34 = AIE.mem(%t34) {
    AIE.terminator(^end)
    ^end:
      AIE.end
  }

  %m43 = AIE.mem(%t43) {
    AIE.terminator(^end)
    ^end:
      AIE.end
  }

  %m32 = AIE.mem(%t32) {
    AIE.terminator(^end)
    ^end:
      AIE.end
  }

  %c23 = AIE.core(%t23) {
    AIE.useToken @token0("Acquire", 1)
    AIE.useToken @token0("Release", 2)
    AIE.end
  }

  %c33 = AIE.core(%t33) {
    AIE.useToken @token3("Acquire", 0)
    AIE.useToken @token2("Acquire", 0)
    AIE.useToken @token1("Acquire", 0)
    AIE.useToken @token0("Acquire", 0)
    AIE.useToken @token0("Release", 1)
    AIE.useToken @token1("Release", 1)
    AIE.useToken @token2("Release", 1)
    AIE.useToken @token3("Release", 1)
    AIE.end
  }

  %c34 = AIE.core(%t34) {
    AIE.useToken @token1("Acquire", 1)
    AIE.useToken @token1("Release", 2)
    AIE.end
  }

  %c43 = AIE.core(%t43) {
    AIE.useToken @token2("Acquire", 1)
    AIE.useToken @token2("Release", 2)
    AIE.end
  }

  %c32 = AIE.core(%t32) {
    AIE.useToken @token3("Acquire", 1)
    AIE.useToken @token3("Release", 2)
    AIE.end
  }
}
