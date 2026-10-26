# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bp3-pg_search adapts `pg_search` for BP3 (persuavis/black_phoebe_3), a multi-site multi-tenant Rails
application. It makes `PgSearch::Document`, the multisearch index, a tenant-scoped BP3 record, so a search
only ever sees the current site's documents. There is nothing to configure: adding the gem is enough.

## Commands

The gems run on Ruby 3.4.6 (`.ruby-version`). Prefix commands with `~/.rvm/bin/rvm 3.4.6 do` when the
shell is not already on it; a missing `rspec` means the wrong Ruby, not a missing bundle.

- `bundle exec rake` - specs and RuboCop (the default task)
- `bundle exec rspec spec/path/to/file_spec.rb[:LINE]` - one file or example
- `bundle exec rubocop` / `bundle exec rubocop -a`
- `bin/setup`, `bin/console`, `rake install`

## Architecture

`lib/bp3/pg_search/railtie.rb` reopens `PgSearch::Document` in an `after_initialize` block and:

- includes `Bp3::Core::Rqid`, `Sqnr`, `Tenantable`, `Displayable` and `Ransackable`, calls
  `configure_tenancy` and `use_sqnr_for_ordering`. Tenantable's default scope is what limits a search to
  the site, and its callbacks fill site and tenant from the request state when a document is written
- adds `table_name_basis` (table name without the `public.` schema prefix) and `controllerize` (from
  bp3-string)
- `version_filter_mask` is `'[FILTERED][PS]'`. Documents are not audited (no `has_paper_trail`)

## Testing

The spec only checks the version; the Railtie needs a Rails application with PostgreSQL to exercise. Try a
change against the application (black_phoebe_3) by putting this repo's `lib` ahead of the bundled gem.

## Code Style

- RuboCop (`.rubocop.yml`): target Ruby 3.2.2, NewCops, rubocop-rake and rubocop-rspec; AbcSize 26,
  MethodLength 15, BlockLength 66, ModuleLength 150; `Lint/ConstantDefinitionInBlock` and `Lint/Void`
  are off for `lib/bp3/**/railtie.rb`, where classes are reopened inside a block
- Every file starts with `# frozen_string_literal: true`
- American English; no trailing whitespace on any added or modified line

## Release

Bump `lib/bp3/pg_search/version.rb` and add a `CHANGELOG.md` entry. `rake release` tags, pushes and
publishes to rubygems.org; leave releasing and committing to the user.
