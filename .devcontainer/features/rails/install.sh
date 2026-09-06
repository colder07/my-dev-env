#!/usr/bin/env bash

set -euo pipefail

RAILS_VERSION="${VERSION}"

if ! command -v gem >/dev/null 2>&1; then
    echo "ERROR: RubyGems is not available. The Ruby Feature must be installed first."
    exit 1
fi

if gem list --installed rails --version "${RAILS_VERSION}" >/dev/null 2>&1; then
    echo "Rails already installed: $(rails --version)"
else
    echo "Installing Rails ${RAILS_VERSION}"
    gem install rails --version "${RAILS_VERSION}" --no-document
fi

if ! command -v rails >/dev/null 2>&1; then
    echo "ERROR: Rails installation completed but the rails command is not available."
    exit 1
fi

echo "Rails ${RAILS_VERSION} setup complete: $(rails --version)"
