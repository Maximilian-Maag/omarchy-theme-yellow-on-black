.PHONY: test check lint mutation

# A theme is data, so the harness is small: the palette's contract plus the installer.
test:
	@bash tools/run_tests.sh

# Everything but the (slow) mutation pass.
check:
	@SKIP_MUTATION=1 bash tools/run_tests.sh

lint:
	@python3 tools/policy_check.py

mutation:
	@python3 tools/mutator.py
