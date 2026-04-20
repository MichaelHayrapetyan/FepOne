# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

This repository is currently an empty scaffold. It contains only `FepOne.xcodeproj/project.xcworkspace` — there is no `project.pbxproj`, no source files, no targets, no tests, and no README. Treat it as a fresh Xcode project workspace awaiting initial setup.

Until the project structure is established, there are no build, lint, or test commands to document. When adding the first code, record the toolchain choices (Swift/Obj-C, iOS/macOS target, SwiftPM vs. Xcode-managed deps, test framework) back into this file so future sessions can build and test without re-discovering them.

## Conventions

- The project root is `/Users/michaelhayrapetyan/FepOne/FepOne`; the Xcode project lives at the same level rather than in a nested `FepOne/` source directory.
- Not a git repository — be aware that changes are not version-controlled unless the user initializes one.
