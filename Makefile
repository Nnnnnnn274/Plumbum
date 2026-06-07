# Makefile for plumbum

.PHONY: all clean build xpf ipa help

# Default target
all: build

# Build the app
build:
	@echo "Building plumbum..."
	xcodebuild -project plumbum.xcodeproj \
		-scheme plumbum \
		-configuration Debug \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

# Build IPA
ipa:
	@echo "Building IPA..."
	./build.sh

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -rf build
	rm -rf plumbum/XPF/output
	cd plumbum/XPF && make clean

# Install dependencies
deps:
	@echo "No external dependencies required"

# Show help
help:
	@echo "Available targets:"
	@echo "  all     - Build the app (default)"
	@echo "  build   - Build the app"
	@echo "  xpf     - Build XPF subproject"
	@echo "  ipa     - Build IPA using build.sh"
	@echo "  clean   - Clean build artifacts"
	@echo "  deps    - Install dependencies"
	@echo "  help    - Show this help message"
