SHELL         := /bin/bash
REQUIRED_RUBY := 3.3.8

.PHONY: help serve publish
.DEFAULT_GOAL := help

# Expands inline into a recipe so the eval'd rbenv init stays in the same
# shell as the command that follows.  Every line except the last ends with \
# so the whole block (plus whatever comes after) is one shell invocation.
define _check_ruby
CURRENT_RUBY=$$(ruby --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1); \
if [[ "$$CURRENT_RUBY" != "$(REQUIRED_RUBY)" ]]; then \
  if ! command -v rbenv &>/dev/null; then \
    echo "Warning: rbenv not found. Please install Ruby $(REQUIRED_RUBY) manually." >&2; \
  else \
    rbenv versions --bare 2>/dev/null | grep -qx "$(REQUIRED_RUBY)" || rbenv install "$(REQUIRED_RUBY)"; \
    rbenv local "$(REQUIRED_RUBY)"; \
    eval "$$(rbenv init - bash)"; \
    bundle install; \
  fi; \
fi;
endef

help:
	@echo "Usage: make <target> [MSG='commit message']"
	@echo ""
	@echo "Targets:"
	@echo "  serve              Serve the site locally for development"
	@echo "  publish MSG=...    Build the site and push changes with the given commit message"

serve:
	@$(_check_ruby) \
	bundle exec jekyll serve

publish:
	@test -n "$(MSG)" || { echo "Error: publish requires MSG='commit message'" >&2; exit 1; }
	@$(_check_ruby) \
	git pull && \
	JEKYLL_ENV=publish bundle exec jekyll build && \
	cd publish && \
	git pull origin master && \
	git checkout master && \
	find . -mindepth 1 -maxdepth 1 -not \( -path ".*\.git" \) -not \( -path ".*CNAME" \) -exec rm -r {} \; && \
	cp -rf ../_site/* . && \
	git add -A && \
	git commit -m "$(MSG)" && \
	git push && \
	cd .. && \
	git add -A && \
	git commit -m "$(MSG)" && \
	git push
