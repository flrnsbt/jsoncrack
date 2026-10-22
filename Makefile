# JsonCrack Flutter Package Makefile
#
# Targets:
#   make html          - Build the JsonCrack HTML asset from source
#   make example-web   - Build the example Flutter web project
#   make run-example   - Run the example Flutter web project in Chrome
#   make clean         - Clean all build artifacts
#   make all           - Build HTML asset and example web project

# Configuration
FVM := fvm
FLUTTER := $(FVM) flutter
EXAMPLE_DIR := example
TMP_DIR := build/tmp_jsoncrack
OUTPUT_DIR := assets/src

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
NC     := \033[0m # No Color

.PHONY: all html example-web run-example export clean


## example-web: Build the example Flutter web project
example-web:
	@echo -e "$(YELLOW)→ Getting example dependencies...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) pub get
	@echo -e "$(YELLOW)→ Building example for web...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) build web --release
	@echo -e "$(GREEN)✓ Example web build complete! Output in $(EXAMPLE_DIR)/build/web/$(NC)"

## run-example: Run the example Flutter web project in Chrome
run-example:
	@echo -e "$(YELLOW)→ Getting example dependencies...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) pub get
	@echo -e "$(YELLOW)→ Running example for web...$(NC)"
	@cd $(EXAMPLE_DIR) && $(FLUTTER) run -d chrome --web-port=8080

## clean: Clean all build artifacts
clean:
	@cd $(EXAMPLE_DIR) && $(FLUTTER) clean

## export: Export the index.html using build-json-crack.sh
export:
	@echo -e "$(YELLOW)→ Exporting index.html via build-json-crack.sh...$(NC)"
	@./build-json-crack.sh "$(TMP_DIR)" "$(OUTPUT_DIR)"
	@echo -e "$(GREEN)✓ Export complete! Output in $(OUTPUT_DIR)/$(NC)"

## help: Show this help message
help:
	@echo "JsonCrack Flutter Package Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  $(BOLD)make example-web$(NC)   - Build the example Flutter web project"
	@echo "  $(BOLD)make run-example$(NC)   - Run the example Flutter web project in Chrome"
	@echo "  $(BOLD)make export$(NC)        - Export the index.html using build-json-crack.sh"
	@echo "  $(BOLD)make clean$(NC)         - Clean all build artifacts"