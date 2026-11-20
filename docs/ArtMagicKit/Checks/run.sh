#!/bin/sh
# Compiles the Foundation-only parsers with Checks/main.swift and runs them. No iOS SDK, no network.
set -e
cd "$(dirname "$0")/.."
out="$(mktemp -d)/parser-checks"
swiftc -o "$out" Sources/Parsing/*.swift Checks/main.swift
"$out"
