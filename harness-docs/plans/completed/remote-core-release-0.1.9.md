# Execution Plan: Publish Remote Harness Core 0.1.9

Date: 2026-08-05

## Status

Completed

## Outcome

The remote installer sourced from branch `vi` downloads a published,
checksum-verified Harness core binary instead of failing with HTTP 404.

## Context

- `scripts/install-harness.sh` resolves `scripts/harness-release-tag` and
  downloads the matching platform asset from GitHub Releases.
- `.github/workflows/post-merge-maintenance.yml` owns releases from branch
  `vi`.
- `.github/workflows/harness-release.yml` builds and publishes five platform
  binaries and their checksums.
- The manually created `harness-v0.1.8` release has no assets and cannot be
  safely mutated under the immutable-release contract.

## Scope

In scope:

- Align core release provenance validation with the repository's `vi` release
  branch.
- Prepare and publish `harness-v0.1.9` with the complete asset inventory.
- Verify the Linux x64 download and the remote installer path.

Out of scope:

- Mutating or deleting the existing `harness-v0.1.8` release.
- Changing the optional compatibility CLI release process.

## Approach

Update core release provenance to require `origin/vi`, bump the core package,
lockfile, and release pin to `0.1.9`, run focused and repository checks, push
the exact proven commit, then dispatch and observe the release workflow.

## Risks And Recovery

- A failed workflow leaves no `harness-v0.1.9` tag because tag promotion occurs
  only after all builds pass; fix forward and rerun the same candidate.
- Once the tag and release are published they are immutable; do not publish
  until local validation passes.
- If remote workflow dispatch credentials are unavailable, leave the validated
  commit unpushed and report the exact external blocker.

## Progress

- [x] Confirm the 0.1.8 release exists with zero assets.
- [x] Align release provenance and prepare 0.1.9.
- [x] Run focused core and installer validation; the full repository gate is
  deferred to release CI because this host lacks its required `sqlite3`.
- [x] Diagnose the first CI run and repair stale executable ownership-map
  references left by the `docs/` to `harness-docs/` relocation.
- [x] Repair the related installer, classifier, documentation, workflow, and
  release-test expectations exposed by the clean-checkout repository contract.
- [x] Push the proven candidate and publish the GitHub release.
- [x] Verify the release asset and remote installer.

## Decisions

- 2026-08-05: Publish a new immutable `0.1.9` release rather than add unproven
  assets to the manually created `0.1.8` release.
- 2026-08-05: Treat `vi` as release authority because the installer defaults,
  post-merge trigger, checkout, and maintenance push all explicitly use `vi`.

## Validation

- Focused proof: core Rust tests, installer modes, release identity, exact asset
  inventory, workflow contract, and recovery contract passed.
- Integration or end-to-end proof: GitHub Actions run `31009517039` passed all
  five native builds and published ten assets; the Linux x64 asset passed its
  published checksum, reported `harness 0.1.9`, and the remote installer
  installed it into `/tmp/tmp.JWOz3i4V3V` with status `current`.
- Repository-required checks: the clean-checkout `scripts/validate-premerge.sh`
  contract passed in GitHub Actions.

## Result

Published immutable release `harness-v0.1.9` from commit
`8bbc1b895349a3d6e2ec0339a608f487ae6c6a11`. The branch-`vi` remote installer
now downloads and installs the checksum-verified platform binary without the
0.1.8 HTTP 404 failure. The empty manually created 0.1.8 release remains
unchanged as historical evidence.
