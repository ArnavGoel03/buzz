.PHONY: setup generate open lint format test clean bootstrap tf

# ── Setup ────────────────────────────────────────────────────────────────────
setup:
	@command -v brew >/dev/null || (echo "Install Homebrew first: https://brew.sh" && exit 1)
	brew bundle --file=Brewfile
	@echo "✓ Toolchain ready. Now: make generate"

# ── Xcode project ────────────────────────────────────────────────────────────
generate:
	xcodegen generate
	@echo "✓ Buzz.xcodeproj regenerated from project.yml"

open: generate
	open Buzz.xcodeproj

# ── Quality ──────────────────────────────────────────────────────────────────
lint:
	swiftlint lint --strict

format:
	swiftformat Buzz BuzzTests
	swiftlint --fix

test:
	xcodebuild test -project Buzz.xcodeproj -scheme Buzz \
	  -destination 'platform=iOS Simulator,name=iPhone 15' | xcpretty

secrets-scan:
	gitleaks detect --source . --config .gitleaks.toml --verbose

# ── Distribution ─────────────────────────────────────────────────────────────
tf:
	bundle exec fastlane beta

# ── Hygiene ──────────────────────────────────────────────────────────────────
clean:
	rm -rf Buzz.xcodeproj ~/Library/Developer/Xcode/DerivedData/Buzz-*

bootstrap: setup generate
	@echo "✓ Bootstrapped. Run: make open"
