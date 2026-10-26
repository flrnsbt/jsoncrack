# JsonCrack Flutter Package Makefile
#
# Targets:
#   make export        - Build and export jsoncrack-react using build-json-crack.sh
#   make example-web   - Build the example Flutter web project
#   make run-example   - Run the example Flutter web project in Chrome
#   make clean         - Clean all build artifacts
#   make help          - Show help message

# Configuration
EXAMPLE_DIR := example
TMP_DIR := build/tmp_jsoncrack
OUTPUT_DIR := example/build/web/

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
NC     := \033[0m # No Color

.PHONY: help export example-web run-example clean

FVM_STANDALONE=$(HOME)/fvm/bin/fvm
GET_FVM= $$(command -v fvm 2>/dev/null || echo "$(FVM_STANDALONE)")
FLUTTER := $(GET_FVM) flutter

ensure-fvm:
	@if command -v fvm >/dev/null 2>&1; then \
		echo "✓ FVM detected in global PATH."; \
	elif [ -x "$(FVM_STANDALONE)" ]; then \
		echo "✓ FVM detected at standalone path: $(FVM_STANDALONE)"; \
	else \
		echo "⚠️ FVM not found. Downloading via official install script..."; \
		curl -fsSL https://fvm.app/install.sh | bash; \
	fi
	@echo "Synchronizing project Flutter SDK version..."
	@$(GET_FVM) install

## example-web: Build the example Flutter web project
example-web: ensure-fvm
	@echo -e "$(YELLOW)→ Getting example dependencies...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) pub get --enforce-lockfile
	@echo -e "$(YELLOW)→ Building example for web...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build web --release --wasm --no-pub --no-web-resources-cdn  --optimization-level=4 --tree-shake-icons --no-source-maps --strip-wasm
	@echo -e "$(GREEN)✓ Example web build complete! Output in $(EXAMPLE_DIR)/build/web/$(NC)"

## run-example: Run the example Flutter web project in Chrome
run-example: ensure-fvm
	@echo -e "$(YELLOW)→ Getting example dependencies...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) pub get
	@echo -e "$(YELLOW)→ Running example for web...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) run -d chrome --web-port=8080

## clean: Clean all build artifacts
clean: ensure-fvm
	@cd $(EXAMPLE_DIR) && $(FLUTTER) clean

## export: Export the index.html using build-json-crack.sh
export:
	@echo -e "$(YELLOW)→ Exporting index.html via build-json-crack.sh...$(NC)"
	@./build-json-crack.sh "$(TMP_DIR)" "$(OUTPUT_DIR)"
	@echo -e "$(GREEN)✓ Export complete! Output in $(OUTPUT_DIR)/$(NC)"

build-ci:
	$(MAKE) example-web
	$(MAKE) export

## help: Show this help message
help:
	@echo "JsonCrack Flutter Package Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  $(BOLD)make example-web$(NC)   - Build the example Flutter web project"
	@echo "  $(BOLD)make run-example$(NC)   - Run the example Flutter web project in Chrome"
	@echo "  $(BOLD)make export$(NC)        - Export the index.html using build-json-crack.sh"
	@echo "  $(BOLD)make clean$(NC)         - Clean all build artifacts"