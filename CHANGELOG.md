# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.7.0] - 2026-01-16

### Added

- Edit issue descriptions directly in Neovim buffer and sync to Jira on save
- Markdown to Atlassian Document Format (ADF) converter for description updates
- Confirmation dialog before syncing changes to Jira

## [v0.6.0] - 2025-12-30

### Added

- Assign issues to yourself with `<C-y>` keybinding in Telescope
- Customizable Telescope keybindings via `telescope_keymaps` configuration

## [v0.5.0] - 2025-12-30

### Added

- Allow passing custom JQL queries directly to `:JiraIssues` command

## [v0.4.0] - 2025-12-29

### Added

- Add issue transitions support with `<C-t>` keybinding in Telescope

## [v0.3.0] - 2025-12-28

### Added

- Add support for `inlineCard` node in adf2md converter

## [v0.2.0] - 2025-12-28

### Added

- Add max results configuration option

## [v0.1.0] - 2025-12-28

### Added

- Initial release
- Add `JiraIssues` command for listing Jira issues
- Preview Jira issues in Telescope with Markdown description
- Basic plugin setup and configuration

[v0.7.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/quiqueporta/jira.nvim/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/quiqueporta/jira.nvim/releases/tag/v0.1.0
