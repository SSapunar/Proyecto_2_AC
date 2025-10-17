# ===== Config =====
VERILOG_FILES = \
  computer.v \
  alu.v \
  pc.v \
  mux2.v \
  instruction_memory.v \
  register.v \
  data_memory.v

# Elegibles en tiempo de ejecución (override con: TESTBENCH_FILE=... IM_SRC=... DEFINES=...)
TESTBENCH_FILE ?= testbench.v
IM_SRC         ?= im.dat
DEFINES        ?=

YOSYS_SCRIPT   = yosys.tcl
IVERILOG_FLAGS = -g2012 -Wall -Wimplicit -Wportbind -Wtimescale

# Rutas de salida (nombre del .vvp depende del testbench)
OUT_DIR        = out
TB_BASE        = $(basename $(notdir $(TESTBENCH_FILE)))
OUT_FILE       = $(OUT_DIR)/$(TB_BASE).vvp
WAVEFORM_FILE  = $(OUT_DIR)/dump.vcd

# GTKWave (Flatpak)
WAVE_SAVE  ?= $(OUT_DIR)/wave.gtkw
GTKWAVE_BIN := flatpak run io.github.gtkwave.GTKWave

# Targets
.PHONY: all build run wave synth clean run-mem run-long run-both wave-mem wave-long stats

all: run

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

# Construir ejecutable de simulación
build: $(OUT_DIR) $(VERILOG_FILES) $(TESTBENCH_FILE)
	@echo "Construyendo ejecutable de simulación..."
	@# Si IM_SRC != im.dat, copiamos para que instruction_memory lo encuentre
	@if [ "$(IM_SRC)" != "im.dat" ]; then \
	  cp -f "$(IM_SRC)" im.dat; \
	else \
	  echo "IM_SRC=im.dat → no se copia"; \
	fi
	iverilog $(IVERILOG_FLAGS) $(DEFINES) -o $(OUT_FILE) $(TESTBENCH_FILE) $(VERILOG_FILES)
	@echo "Construcción OK → $(OUT_FILE)"

# Ejecutar simulación
run: build
	@echo "Ejecutando simulación..."
	vvp $(OUT_FILE)

# Ver formas de onda (Flatpak siempre)
wave: run
	@echo "Abriendo GTKWave (Flatpak)..."
	@if [ ! -f "$(WAVEFORM_FILE)" ]; then \
	  echo "No existe $(WAVEFORM_FILE). Corre 'make run' primero."; exit 1; \
	fi
	@if [ -f "$(WAVE_SAVE)" ]; then \
	  $(GTKWAVE_BIN) "$(WAVEFORM_FILE)" "$(WAVE_SAVE)" & \
	else \
	  $(GTKWAVE_BIN) "$(WAVEFORM_FILE)" & \
	fi

# Atajos para el banco con memoria (usa testbench_memory.v + im_memory.dat)
run-mem:
	$(MAKE) run TESTBENCH_FILE=testbench_memory.v IM_SRC=im_memory.dat DEFINES=

wave-mem:
	$(MAKE) wave TESTBENCH_FILE=testbench_memory.v IM_SRC=im_memory.dat DEFINES=

# Banco largo (usa testbench.v + im.dat y NO pisa con im_memory.dat)
run-long:
	$(MAKE) run TESTBENCH_FILE=testbench.v IM_SRC=im.dat DEFINES=-DNO_TB_LOAD

wave-long:
	$(MAKE) wave TESTBENCH_FILE=testbench.v IM_SRC=im.dat DEFINES=-DNO_TB_LOAD

# Corre ambos en secuencia limpia
run-both:
	$(MAKE) clean
	$(MAKE) run-mem
	$(MAKE) clean
	$(MAKE) run-long

# Síntesis (opcional)
synth: $(OUT_DIR)
	@echo "Iniciando síntesis lógica con Yosys..."
	yosys -c $(YOSYS_SCRIPT)
	@echo "Síntesis completa."

stats:
	yosys -p 'read_verilog -sv computer.v alu.v pc.v mux2.v instruction_memory.v register.v; hierarchy -check -top computer; stat'

# Limpiar
clean:
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR)
	@rm -f yosys.log
	@echo "Limpieza completa."
