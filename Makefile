# Makefile for building LaTeX files with rubber

# Define the directories
BUILD_DIR := build
TEMPLATE_DIR := template

# List of LaTeX files to build
TEX_FILES := $(wildcard *.tex)
BIB_FILES := $(wildcard *.bib)

# List of other files related to build
SUB_DIRS := $(shell find . -maxdepth 1 -type d ! -path "./.git*" ! -path ".")
SUB_DIRS := $(filter-out ./$(BUILD_DIR), $(SUB_DIRS))
SUB_DIRS := $(filter-out ./$(TEMPLATE_DIR), $(SUB_DIRS))

# Default target
.PHONY: all
all: $(TEX_FILES:%.tex=$(BUILD_DIR)/%.pdf) $(BIB_FILES)

# Rule for building LaTeX files
$(BUILD_DIR)/%.pdf: %.tex $(BIB_FILES) $(TEMPLATE_DIR)/* $(SUB_DIRS)/* | $(BUILD_DIR)
	@echo "Moving build files"
	@cp -f -r -t $(BUILD_DIR)/ $(TEX_FILES) $(BIB_FILES) $(SUB_DIRS) $(TEMPLATE_DIR)/*
	@echo ""
	@echo "Building"
	@cd $(BUILD_DIR) && rubber --pdf $(<F)

# Rule to create the build directory
$(BUILD_DIR):
	@echo "Making build directory"
	@mkdir -p $(BUILD_DIR)

# Insert declaration page
.PHONY: insert-declaration
insert-declaration: all
	@echo ""
	@echo "Inserting declaration"
	@pdftk A=$(BUILD_DIR)/thesis.pdf B=$(BUILD_DIR)/declaration-test.pdf cat A1 B1 A3-end output $(BUILD_DIR)/thesis-SIGNED.pdf
	@echo "Extracting metadata"
	@pdftk $(BUILD_DIR)/thesis.pdf dump_data output $(BUILD_DIR)/title.txt
	@echo "Inserting metadata"
	@pdftk $(BUILD_DIR)/thesis-SIGNED.pdf update_info $(BUILD_DIR)/title.txt output thesis.pdf

# Clean the build directory
.PHONY: clean
clean:
	@echo "Removing build directory"
	@rm -rf $(BUILD_DIR)

# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Do everything
.PHONY: full
full: rebuild insert-declaration

# Spellcheck target
.PHONY: spellcheck
spellcheck:
	@for file in $(TEX_FILES); do \
		aspell --lang=en --mode=tex check $$file; \
	done
