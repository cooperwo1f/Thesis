# Makefile for building LaTeX files with rubber

# Define the directories
BUILD_DIR := build
TEMPLATE_DIR := template

# List of LaTeX files to build
TEX_FILES := $(wildcard *.tex)
BIB_FILES := $(wildcard *.bib)

# Default target
all: $(TEX_FILES:%.tex=$(BUILD_DIR)/%.pdf) $(BIB_FILES)

# Rule for building LaTeX files
$(BUILD_DIR)/%.pdf: %.tex $(BIB_FILES) $(TEMPLATE_DIR)/* | $(BUILD_DIR)
	cp $(TEMPLATE_DIR)/* $(BUILD_DIR)/
	cp -t $(BUILD_DIR)/ $(TEX_FILES) $(BIB_FILES)
	cd $(BUILD_DIR) && rubber --pdf $(<F)

# Rule to create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean the build directory
clean:
	rm -rf $(BUILD_DIR)

# Clean and rebuild
rebuild: clean all

# Spellcheck target
spellcheck:
	@for file in $(TEX_FILES); do \
		aspell --lang=en --mode=tex check $$file; \
	done

# Phony targets
.PHONY: all clean rebuild spellcheck
