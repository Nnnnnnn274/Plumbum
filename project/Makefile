# Makefile for plumbum
# NOTE: This project is designed to be built via GitHub Actions CI
# Local building requires macOS with Xcode installed

.PHONY: all clean build ipa help

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
	@echo "NOTE: This requires macOS with Xcode installed"
	@echo "For automated building, push to GitHub to trigger CI"
	@./build.sh || { \
		echo "IPA build failed!"; \
		echo "Reason: build.sh script failed"; \
		echo "Solution: Use GitHub Actions CI or build on macOS with Xcode"; \
		exit 1; \
	}

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf build || { \
		echo "Clean failed!"; \
		echo "Reason: Could not remove build directories"; \
		echo "Possible causes:"; \
		echo "  - Files are in use by another process"; \
		echo "  - Insufficient permissions"; \
		echo "Solution: Close Xcode and try again"; \
		exit 1; \
	}

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
