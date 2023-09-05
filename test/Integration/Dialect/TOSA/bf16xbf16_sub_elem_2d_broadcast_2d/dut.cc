// clang-format off
void dut(bfloat16 * restrict v1, bfloat16 * restrict v2, bfloat16 * restrict v3) {
  bfloat16 * restrict v4 = v2;
  size_t v5 = 0;
  size_t v6 = 16;
  size_t v7 = 1;
  for (size_t v8 = v5; v8 < v6; v8 += v7)
  chess_prepare_for_pipelining
  chess_loop_range(16, 16)
  {
    size_t v9 = 0;
    size_t v10 = 1024;
    size_t v11 = 16;
    for (size_t v12 = v9; v12 < v10; v12 += v11)
    chess_prepare_for_pipelining
    chess_loop_range(64, 64)
    {
      v16bfloat16 v13 = *(v16bfloat16 *)(v1 + 1024*v8+v12);
      v16bfloat16 v14 = *(v16bfloat16 *)(v4 + v12);
      v16accfloat v15 = ups_to_v16accfloat(v13);
      v16accfloat v16 = ups_to_v16accfloat(v14);
      v16accfloat v17 = sub(v15, v16);
      v16bfloat16 v18 = to_v16bfloat16(v17);
      *(v16bfloat16 *)(v3 + 1024*v8+v12) = v18;
    }
  }
  return;
}
// clang-format on
