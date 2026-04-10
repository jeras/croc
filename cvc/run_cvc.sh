cvc64 +define+CVC \
+define+TRACE_WAVE \
+define+FUNCTIONAL \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_64x64_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_256x64_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_512x64_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_1024x64_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_2048x64_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_sram/verilog/RM_IHPSG13_1P_256x48_c2_bm_bist.v \
../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v \
../ihp13/bondpad/verilog/bondpad_70x70.v \
../openroad/out/croc.v \
-sv ../rtl/test/tb_croc_chip.sv \
+maxdelays +sdf_annotate ../openroad/out/croc.sdf