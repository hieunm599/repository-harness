#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-harness.sh [options] [path]

Bootstrap the Rust `harness` CLI and install the Harness core into a target.

Options:
  -d, --directory <path>  Target directory. Defaults to the current directory.
  -y, --yes              Accept defaults and skip prompts.
      --with-engineering-wisdom
                         Add the explicit-only engineering-wisdom advisory
                         skill. It is excluded from the default core.
      --merge            On protected-path conflict, keep existing files in
                         place and install only missing Harness files.
      --refresh-agent-shim
                         Refresh an existing AGENTS.md into the small Harness
                         shim after backing it up. Old Harness-generated files
                         are replaced; custom files receive a marked block.
      --claude           Also install or refresh CLAUDE.md so Claude Code
                         auto-loads the harness context. Claude Code never
                         auto-loads AGENTS.md; the shim @-imports AGENTS.md
                         as its single policy source inside a marked block.
                         Existing CLAUDE.md files get the block appended
                         after a backup; a stale block is refreshed in place.
      --override         On protected-path conflict, back up and replace
                         AGENTS.md and harness-docs/.
      --force            Overwrite existing files after backing them up.
      --dry-run          Show what would change without writing files.
  -h, --help             Show this help.

Safety:
  The installer installs the repository-centered core plus the Rust
  maintenance CLI. It performs no compatibility CLI or SQLite/control-plane
  download and no database write. If AGENTS.md or harness-docs/ already exist,
  interactive installs ask
  whether to merge missing files, override after backup, or stop. Merge is the
  safe update path for repositories that already have Harness: existing files
  stay in place and new Harness files are appended by path. Non-
  interactive installs stop unless --merge or --override is provided. If a
  target .gitignore receives only the Rust maintenance binary rules.

Examples:
  scripts/install-harness.sh
  scripts/install-harness.sh --directory /path/to/project --yes
  scripts/install-harness.sh --directory /path/to/project --with-engineering-wisdom --yes
  scripts/install-harness.sh ./my-project --force
  curl -fsSL https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh | bash -s -- --yes
  curl -fsSL https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh | bash -s -- --merge --yes
  curl -fsSL https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh | bash -s -- --merge --refresh-agent-shim --yes
  curl -fsSL https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh | bash -s -- --claude --yes
EOF
}

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

warn_stop() {
  printf 'Warning: %s\n' "$*" >&2
  exit 1
}

expand_path() {
  local path="$1"
  case "$path" in
    ~/*|~)
      printf '%s%s\n' "$HOME" "${path#~}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

make_absolute_parent() {
  local target="$1"
  if [ -d "$target" ]; then
    (cd "$target" && pwd -P)
    return 0
  fi

  local parent
  parent="$(dirname "$target")"
  local base
  base="$(basename "$target")"

  if [ -d "$parent" ]; then
    printf '%s/%s\n' "$(cd "$parent" && pwd -P)" "$base"
  else
    fail "Parent directory does not exist for target: $target"
  fi
}

can_prompt() {
  [ -t 0 ] && [ -t 1 ] && [ -c /dev/tty ]
}

prompt_tty() {
  printf '%s' "$1" > /dev/tty
}

read_tty() {
  local reply
  read -r reply < /dev/tty
  printf '%s\n' "$reply"
}

read_remote_text() {
  local url="$1"
  case "$url" in
    file://*)
      local path="${url#file://}"
      [ -f "$path" ] || fail "Could not read local URL: $url"
      cat "$path"
      ;;
    *)
      curl -fsSL "$url" || fail "Could not download $url"
      ;;
  esac
}

read_source_text() {
  local relative_path="$1"
  if [ "$SOURCE_MODE" = "local" ]; then
    [ -f "$SOURCE_ROOT/$relative_path" ] || fail "Missing local source file: $SOURCE_ROOT/$relative_path"
    cat "$SOURCE_ROOT/$relative_path"
  else
    read_remote_text "$SOURCE_BASE_URL/$relative_path"
  fi
}

write_source_file() {
  local relative="$1" target="$2"

  if [ "$relative" = "AGENTS.md" ]; then
    local block
    block="$(agent_shim_block | sed -e :a -e '/^\n*$/{$d;N;ba}')"
    {
      printf '# Agent Instructions\n\n'
      printf 'Add project-specific agent instructions here.\n\n'
      printf '%s\n' "$block"
    } > "$target"
    return 0
  fi

  if [ "$SOURCE_MODE" = "local" ]; then
    local source="$SOURCE_ROOT/$relative"
    [ -f "$source" ] || fail "Source file missing: $source"
    cp -p "$source" "$target"
    return 0
  fi

  local url="$SOURCE_BASE_URL/$relative"
  case "$url" in
    file://*)
      cp -p "${url#file://}" "$target"
      ;;
    *)
      download_file "$url" "$target"
      ;;
  esac
}

read_payload_manifest() {
  local manifest_rel="$1"

  if [ "$SOURCE_MODE" = "local" ]; then
    [ -f "$SOURCE_ROOT/$manifest_rel" ] || fail "Payload manifest missing: $SOURCE_ROOT/$manifest_rel"
    cat "$SOURCE_ROOT/$manifest_rel"
  else
    read_remote_text "$SOURCE_BASE_URL/$manifest_rel"
  fi
}

copy_file() {
  local relative="$1"
  local dest="$TARGET_DIR/$relative"

  if [ -e "$dest" ]; then
    if [ "$CONFLICT_ACTION" = "merge" ]; then
      log "skip     $relative (merge keeps existing file)"
      SKIPPED=$((SKIPPED + 1))
    elif [ "$FORCE" -eq 1 ]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        log "overwrite $relative (backup first)"
      else
        mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
        cp -p "$dest" "$BACKUP_DIR/$relative"
        write_source_file "$relative" "$dest"
        log "updated  $relative (backup: ${BACKUP_DIR#$TARGET_DIR/}/$relative)"
      fi
      UPDATED=$((UPDATED + 1))
    else
      log "skip     $relative (already exists)"
      SKIPPED=$((SKIPPED + 1))
    fi
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "create   $relative"
  else
    mkdir -p "$(dirname "$dest")"
    write_source_file "$relative" "$dest"
    log "created  $relative"
  fi
  CREATED=$((CREATED + 1))
}

copy_manifest_files() {
  local payload_manifest="$1"
  local manifest
  local relative

  manifest="$(read_payload_manifest "$payload_manifest")"
  while IFS= read -r relative || [ -n "$relative" ]; do
    relative="${relative%$'\r'}"
    case "$relative" in
      ""|\#*)
        continue
        ;;
    esac
    copy_file "$relative"
  done <<EOF
$manifest
EOF
}

agent_shim_block() {
  read_source_text "scripts/agent-harness-block.md"
}

claude_shim_block() {
  read_source_text "scripts/claude-harness-block.md"
}

is_old_harness_agent_file() {
  local target="$1"

  grep -Fxq "# Agent Operating Guide" "$target" &&
    grep -Fxq "This repository is in Harness v0. There is no product implementation yet." "$target" &&
    grep -Fxq "## Source Of Truth" "$target" &&
    grep -Fxq "## Task Loop" "$target" &&
    grep -Fxq "## Done Definition" "$target"
}

backup_agent_file() {
  local target="$TARGET_DIR/AGENTS.md"

  [ -e "$target" ] || return 0
  mkdir -p "$BACKUP_DIR"
  [ -e "$BACKUP_DIR/AGENTS.md" ] && return 0
  cp -p "$target" "$BACKUP_DIR/AGENTS.md"
}

extract_obvious_agent_custom_section() {
  local target="$1"
  local output="$2"

  awk '
    /^## (Project-specific|Project Specific|Local|Custom).*Instructions/ {
      capture = 1
      print
      next
    }
    /^## / && capture {
      capture = 0
    }
    capture {
      print
    }
  ' "$target" > "$output"
}

insert_agent_custom_section() {
  local target="$1"
  local custom="$2"
  local tmp

  [ -s "$custom" ] || return 0
  tmp="$(mktemp)"
  awk '
    $0 == "Add project-specific agent instructions here." {
      while ((getline line < custom_file) > 0) {
        print line
      }
      inserted = 1
      next
    }
    { print }
    END {
      if (!inserted) {
        print ""
        while ((getline line < custom_file) > 0) {
          print line
        }
      }
    }
  ' custom_file="$custom" "$target" > "$tmp"
  mv "$tmp" "$target"
}

append_or_replace_agent_harness_block() {
  local target="$TARGET_DIR/AGENTS.md"
  local block_tmp tmp

  block_tmp="$(mktemp)"
  agent_shim_block >"$block_tmp"
  [ -s "$block_tmp" ] || fail "canonical AGENTS.md Harness block is empty"
  tmp="$(mktemp)"
  if grep -Fq "<!-- HARNESS:BEGIN -->" "$target" &&
     grep -Fq "<!-- HARNESS:END -->" "$target"; then
    awk '
      /<!-- HARNESS:BEGIN -->/ {
        while ((getline line < block_file) > 0) {
          print line
        }
        in_block = 1
        next
      }
      /<!-- HARNESS:END -->/ && in_block {
        in_block = 0
        next
      }
      !in_block { print }
    ' block_file="$block_tmp" "$target" > "$tmp"
  else
    {
      cat "$target"
      printf '\n'
      agent_shim_block
    } > "$tmp"
  fi
  mv "$tmp" "$target"
  rm -f "$block_tmp"
}

validate_harness_markers() {
  local target="$1" label="$2"
  local begin_count end_count begin_line end_line
  begin_count=$(grep -Fc '<!-- HARNESS:BEGIN -->' "$target" || true)
  end_count=$(grep -Fc '<!-- HARNESS:END -->' "$target" || true)
  if [ "$begin_count" -eq 0 ] && [ "$end_count" -eq 0 ]; then
    return 0
  fi
  if [ "$begin_count" -ne 1 ] || [ "$end_count" -ne 1 ]; then
    fail "$label must contain exactly one complete Harness marker pair"
  fi
  begin_line=$(grep -Fn '<!-- HARNESS:BEGIN -->' "$target" | cut -d: -f1)
  end_line=$(grep -Fn '<!-- HARNESS:END -->' "$target" | cut -d: -f1)
  [ "$begin_line" -lt "$end_line" ] || fail "$label Harness markers are out of order"
}

refresh_agent_shim() {
  [ "$REFRESH_AGENT_SHIM" -eq 1 ] || return 0

  local target="$TARGET_DIR/AGENTS.md"
  [ -e "$target" ] || return 0

  if [ "$SOURCE_MODE" = "local" ] && [ "$SOURCE_ROOT/AGENTS.md" -ef "$target" ]; then
    log "skip     AGENTS.md (source file)"
    return 0
  fi

  validate_harness_markers "$target" "AGENTS.md"

  if [ "$DRY_RUN" -eq 1 ]; then
    if is_old_harness_agent_file "$target"; then
      log "refresh  AGENTS.md (old Harness guide -> shim, backup first)"
    else
      log "refresh  AGENTS.md (append or replace marked Harness block, backup first)"
    fi
    UPDATED=$((UPDATED + 1))
    return 0
  fi

  backup_agent_file
  if is_old_harness_agent_file "$target"; then
    local custom_tmp
    custom_tmp="$(mktemp)"
    extract_obvious_agent_custom_section "$target" "$custom_tmp"
    write_source_file "AGENTS.md" "$target"
    insert_agent_custom_section "$target" "$custom_tmp"
    rm -f "$custom_tmp"
    log "updated  AGENTS.md (old Harness guide -> shim; backup: ${BACKUP_DIR#$TARGET_DIR/}/AGENTS.md)"
  else
    append_or_replace_agent_harness_block
    log "updated  AGENTS.md (refreshed Harness block; backup: ${BACKUP_DIR#$TARGET_DIR/}/AGENTS.md)"
  fi
  UPDATED=$((UPDATED + 1))
}

backup_claude_file() {
  local target="$TARGET_DIR/CLAUDE.md"

  [ -e "$target" ] || return 0
  mkdir -p "$BACKUP_DIR"
  [ -e "$BACKUP_DIR/CLAUDE.md" ] && return 0
  cp -p "$target" "$BACKUP_DIR/CLAUDE.md"
}

write_claude_shim() {
  [ "$INSTALL_CLAUDE_SHIM" -eq 1 ] || return 0

  local target="$TARGET_DIR/CLAUDE.md"
  local block_tmp tmp

  if [ "$SOURCE_MODE" = "local" ] && [ -e "$target" ] &&
     [ "$SOURCE_ROOT/CLAUDE.md" -ef "$target" ]; then
    log "skip     CLAUDE.md (source file)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ -e "$target" ]; then
    validate_harness_markers "$target" "CLAUDE.md"
  fi

  block_tmp="$(mktemp)"
  tmp="$(mktemp)"
  claude_shim_block > "$block_tmp"

  if [ -e "$target" ] &&
     grep -Fq "<!-- HARNESS:BEGIN -->" "$target" &&
     grep -Fq "<!-- HARNESS:END -->" "$target"; then
    local current_tmp
    current_tmp="$(mktemp)"
    awk '
      /<!-- HARNESS:BEGIN -->/ { in_block = 1 }
      !in_block { print }
      /<!-- HARNESS:END -->/ { in_block = 0 }
    ' "$target" > "$current_tmp"
    {
      cat "$current_tmp"
      claude_shim_block
    } > "$tmp"
    rm -f "$current_tmp"
  elif [ -e "$target" ]; then
    {
      cat "$target"
      printf '\n'
      claude_shim_block
    } > "$tmp"
  else
    {
      printf '# Project Rules\n\n'
      claude_shim_block
    } > "$tmp"
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -e "$target" ]; then
      log "update   CLAUDE.md (shim refreshed)"
      UPDATED=$((UPDATED + 1))
    else
      log "create   CLAUDE.md"
      CREATED=$((CREATED + 1))
    fi
    rm -f "$block_tmp" "$tmp"
    return 0
  fi

  backup_claude_file
  if [ -e "$target" ]; then
    UPDATED=$((UPDATED + 1))
    log "updated  CLAUDE.md (shim refreshed)"
  else
    CREATED=$((CREATED + 1))
    log "created  CLAUDE.md"
  fi
  mkdir -p "$(dirname "$target")"
  mv "$tmp" "$target"
  rm -f "$block_tmp"
}

download_file() {
  local url="$1" target="$2"
  case "$url" in
    file://*)
      cp -p "${url#file://}" "$target"
      ;;
    *)
      curl -fsSL "$url" -o "$target" || fail "Could not download $url"
      ;;
  esac
}

read_harness_release_tag() {
  local tag_file="scripts/harness-release-tag"
  local tag=""
  if [ -n "${HARNESS_CORE_RELEASE_TAG:-}" ]; then
    printf '%s\n' "$HARNESS_CORE_RELEASE_TAG"
    return
  fi
  if [ "$SOURCE_MODE" = "local" ]; then
    [ -f "$SOURCE_ROOT/$tag_file" ] &&
      tag="$(awk 'NF && $1 !~ /^#/ { print $1; exit }' "$SOURCE_ROOT/$tag_file")"
  else
    local tag_tmp
    tag_tmp="$(mktemp)"
    if curl -fsSL "$CORE_SOURCE_BASE_URL/$tag_file" -o "$tag_tmp" 2>/dev/null; then
      tag="$(awk 'NF && $1 !~ /^#/ { print $1; exit }' "$tag_tmp")"
    fi
    rm -f "$tag_tmp"
  fi

  if [ -z "$tag" ]; then
    tag="harness-v0.1.8"
  fi
  printf '%s\n' "$tag"
}

sha256_file() {
  local target="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target" | awk '{ print $1; exit }'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{ print $1; exit }'
  else
    fail "shasum or sha256sum is required for checksum verification"
  fi
}

detect_cli_platform() {
  if [ -n "${HARNESS_CORE_PLATFORM:-}" ]; then
    printf '%s\n' "$HARNESS_CORE_PLATFORM"
    return
  fi
  if [ -n "${HARNESS_CORE_CLI_PLATFORM:-}" ]; then
    printf '%s\n' "$HARNESS_CORE_CLI_PLATFORM"
    return
  fi

  local os
  os="$(uname -s 2>/dev/null || printf '')"
  local arch
  arch="$(uname -m 2>/dev/null || printf '')"

  case "$os" in
    Darwin)
      case "$arch" in
        arm64|aarch64) printf 'macos-arm64\n' ;;
        x86_64) printf 'macos-x64\n' ;;
        *) fail "Unsupported macOS architecture for Harness core maintenance binary: $arch" ;;
      esac
      ;;
    Linux)
      case "$arch" in
        x86_64) printf 'linux-x64\n' ;;
        arm64|aarch64) printf 'linux-arm64\n' ;;
        *) fail "Unsupported Linux architecture for Harness core maintenance binary: $arch" ;;
      esac
      ;;
    *)
      fail "Unsupported operating system for Harness core maintenance binary: $os"
      ;;
  esac
}

stage_harness_core_cli() {
  CORE_STAGE_ROOT="$(mktemp -d)"
  CORE_STAGED_BINARY="$CORE_STAGE_ROOT/harness"
  CORE_PLATFORM="$(detect_cli_platform)"
  CORE_BINARY_NAME="harness-$CORE_PLATFORM"
  if [ -n "${HARNESS_CORE_BINARY:-}" ]; then
    [ -x "$HARNESS_CORE_BINARY" ] || fail "HARNESS_CORE_BINARY is not executable: $HARNESS_CORE_BINARY"
    cp "$HARNESS_CORE_BINARY" "$CORE_STAGED_BINARY"
  elif [ "$SOURCE_MODE" = "local" ]; then
    command -v cargo >/dev/null 2>&1 || fail "cargo is required for a local Harness source install"
    cargo build --quiet --manifest-path "$SOURCE_ROOT/Cargo.toml" -p harness --locked
    cp "$SOURCE_ROOT/target/debug/harness" "$CORE_STAGED_BINARY"
  else
    local release_tag base_url binary_url checksum_url checksum_tmp expected actual
    if [ -n "${CORE_PENDING_VERSION:-}" ]; then
      release_tag="harness-v$CORE_PENDING_VERSION"
    else
      release_tag="$(read_harness_release_tag)"
    fi
    [[ "$release_tag" =~ ^harness-v[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9]+)*$ ]] ||
      fail "invalid Harness core release tag: $release_tag"
    base_url="${HARNESS_CORE_CLI_BASE_URL:-https://github.com/hieunm599/repository-harness/releases/download/$release_tag}"
    binary_url="${base_url%/}/$CORE_BINARY_NAME"
    checksum_url="$binary_url.sha256"
    checksum_tmp="$CORE_STAGE_ROOT/$CORE_BINARY_NAME.sha256"
    download_file "$binary_url" "$CORE_STAGED_BINARY"
    download_file "$checksum_url" "$checksum_tmp"
    expected="$(awk '{ print $1; exit }' "$checksum_tmp")"
    actual="$(sha256_file "$CORE_STAGED_BINARY")"
    [ -n "$expected" ] && [ "$expected" = "$actual" ] ||
      fail "Checksum mismatch for $CORE_BINARY_NAME: expected $expected, got $actual"
    chmod 755 "$CORE_STAGED_BINARY"
    local reported_version
    reported_version="$("$CORE_STAGED_BINARY" --version | awk '{ print $NF; exit }')"
    [ "$reported_version" = "${release_tag#harness-v}" ] ||
      fail "Harness core release identity mismatch for $CORE_BINARY_NAME: tag $release_tag reported version $reported_version"
  fi
  chmod 755 "$CORE_STAGED_BINARY"
}

install_harness_core() {
  local command="install"
  [ -f "$TARGET_DIR/.harness-core/manifest.json" ] && command="update"
  CORE_PENDING_VERSION=""
  if [ "$command" = "update" ] && [ -f "$TARGET_DIR/.harness-core/update/session.json" ]; then
    CORE_PENDING_VERSION="$(sed -n 's/.*"to_version":[[:space:]]*"\([^"]*\)".*/\1/p' "$TARGET_DIR/.harness-core/update/session.json" | head -n 1)"
    [ -n "$CORE_PENDING_VERSION" ] || fail "could not read pending Harness update version"
  fi

  stage_harness_core_cli

  local args=("$command" --directory "$TARGET_DIR")
  [ "$command" = "update" ] && args+=(--candidate)
  [ -n "$CORE_PENDING_VERSION" ] && args+=(--continue)
  [ "$DRY_RUN" -eq 1 ] && args+=(--dry-run)
  local runner="$CORE_STAGED_BINARY"
  local binary_target="" binary_temp=""
  if [ "$DRY_RUN" -eq 0 ]; then
    binary_target="$TARGET_DIR/scripts/bin/harness"
    binary_temp="$TARGET_DIR/scripts/bin/.harness.$$.tmp"
    [ ! -L "$TARGET_DIR/scripts" ] || fail "refusing symlink for repository scripts directory"
    [ ! -L "$TARGET_DIR/scripts/bin" ] || fail "refusing symlink for repository scripts/bin directory"
    [ ! -L "$binary_target" ] || fail "refusing symlink for repository Harness executable"
    mkdir -p "$(dirname "$binary_target")"
    cp "$CORE_STAGED_BINARY" "$binary_temp"
    chmod 755 "$binary_temp"
    if [ -e "$binary_target" ]; then
      mkdir -p "$BACKUP_DIR/scripts/bin"
      cp -p "$binary_target" "$BACKUP_DIR/scripts/bin/harness"
    fi
  fi
  set +e
  "$runner" "${args[@]}"
  local command_status=$?
  set -e
  if [ "$command_status" -eq 2 ] && [ "$DRY_RUN" -eq 0 ]; then
    local retained="$TARGET_DIR/.harness-core/update-candidate/harness"
    [ ! -L "$TARGET_DIR/.harness-core" ] || fail "refusing symlink for .harness-core"
    [ ! -L "$TARGET_DIR/.harness-core/update-candidate" ] || fail "refusing symlink for retained candidate directory"
    [ ! -L "$retained" ] || fail "refusing symlink for retained update candidate"
    mkdir -p "$(dirname "$retained")"
    cp "$CORE_STAGED_BINARY" "$retained"
    chmod 755 "$retained"
  fi
  if [ "$command_status" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    mv -f "$binary_temp" "$binary_target"
    rm -rf "$TARGET_DIR/.harness-core/update-candidate"
    merge_core_gitignore "$TARGET_DIR/.gitignore"
    log "installed scripts/bin/harness ($CORE_PLATFORM)"
  elif [ -n "$binary_temp" ]; then
    rm -f "$binary_temp"
  fi
  rm -rf "$CORE_STAGE_ROOT"
  CORE_STAGE_ROOT=""
  if [ "$command_status" -eq 2 ]; then
    fail "Harness core update needs resolution; edit .harness-core/update/resolved/, then rerun this installer or harness update --continue"
  fi
  [ "$command_status" -eq 0 ] || fail "harness $command failed with exit code $command_status"
}

merge_core_gitignore() {
  local gitignore="$1"
  local entries=("scripts/bin/harness" "scripts/bin/harness.exe")
  local entry

  if [ "$DRY_RUN" -eq 1 ]; then
    return 0
  fi

  if [ ! -f "$gitignore" ]; then
    mkdir -p "$(dirname "$gitignore")"
    {
      printf '# Downloaded Harness binaries for installed project instances.\n'
      for entry in "${entries[@]}"; do
        printf '%s\n' "$entry"
      done
    } > "$gitignore"
    return 0
  fi

  for entry in "${entries[@]}"; do
    if ! grep -Fxq "$entry" "$gitignore"; then
      printf '%s\n' "$entry" >> "$gitignore"
    fi
  done
}

check_protected_target_paths() {
  local conflicts=()

  [ -e "$TARGET_DIR/AGENTS.md" ] && conflicts+=("AGENTS.md")
  [ -e "$TARGET_DIR/harness-docs" ] && conflicts+=("harness-docs/")
  [ "${#conflicts[@]}" -gt 0 ] || return 0

  local joined=""
  local item
  for item in "${conflicts[@]}"; do
    if [ -n "$joined" ]; then
      joined="$joined, $item"
    else
      joined="$item"
    fi
  done

  case "$REQUESTED_CONFLICT_ACTION" in
    merge)
      CONFLICT_ACTION="merge"
      log "Continuing with merge. Existing files will be skipped."
      return 0
      ;;
    override)
      CONFLICT_ACTION="override"
      override_protected_target_paths
      return 0
      ;;
    stop)
      warn_stop "target already contains protected Harness paths: $joined. Refusing to install so existing project instructions or docs are not mixed or overwritten."
      ;;
  esac

  if [ "$YES" -eq 1 ] || ! can_prompt; then
    warn_stop "target already contains protected Harness paths: $joined. Refusing to install so existing project instructions or docs are not mixed or overwritten. Use an empty target directory, or move those paths before running the installer."
  fi

  {
    printf 'Warning: target already contains protected Harness paths: %s\n' "$joined"
    printf 'Choose how to continue:\n'
    printf '  1. Merge    Copy missing Harness files and skip existing files\n'
    printf '  2. Override Back up and replace AGENTS.md and harness-docs/\n'
    printf '  3. Stop     Exit without writing files (recommended)\n'
  } > /dev/tty
  prompt_tty 'Choice [1/2/3, default 3]: '

  local choice
  choice="$(read_tty)"
  case "$choice" in
    1|m|M|merge|Merge)
      CONFLICT_ACTION="merge"
      log "Continuing with merge. Existing files will be skipped."
      ;;
    2|o|O|override|Override)
      CONFLICT_ACTION="override"
      override_protected_target_paths
      ;;
    ""|3|s|S|stop|Stop)
      warn_stop "installation stopped by user."
      ;;
    *)
      warn_stop "unknown choice: $choice"
      ;;
  esac
}

override_protected_target_paths() {
  local protected

  for protected in AGENTS.md harness-docs; do
    [ -e "$TARGET_DIR/$protected" ] || continue

    if [ "$DRY_RUN" -eq 1 ]; then
      log "override $protected (backup first)"
      continue
    fi

    mkdir -p "$BACKUP_DIR"
    mv "$TARGET_DIR/$protected" "$BACKUP_DIR/$protected"
    log "removed  $protected (backup: ${BACKUP_DIR#$TARGET_DIR/}/$protected)"
  done
}

install_engineering_wisdom() {
  [ "$INSTALL_ENGINEERING_WISDOM" -eq 1 ] || return 0
  copy_manifest_files "$ENGINEERING_WISDOM_PAYLOAD_MANIFEST"
}

TARGET_INPUT="${HARNESS_TARGET_DIR:-$PWD}"
YES=0
FORCE=0
DRY_RUN=0
INSTALL_ENGINEERING_WISDOM=0
REFRESH_AGENT_SHIM=0
INSTALL_CLAUDE_SHIM=0
REQUESTED_CONFLICT_ACTION=""
POSITIONAL_TARGET=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--directory)
      [ "$#" -ge 2 ] || fail "$1 requires a path"
      TARGET_INPUT="$2"
      shift 2
      ;;
    -y|--yes)
      YES=1
      shift
      ;;
    --with-engineering-wisdom)
      INSTALL_ENGINEERING_WISDOM=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --merge)
      REQUESTED_CONFLICT_ACTION="merge"
      shift
      ;;
    --refresh-agent-shim)
      REFRESH_AGENT_SHIM=1
      shift
      ;;
    --claude)
      INSTALL_CLAUDE_SHIM=1
      shift
      ;;
    --override)
      REQUESTED_CONFLICT_ACTION="override"
      shift
      ;;
    --stop)
      REQUESTED_CONFLICT_ACTION="stop"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      fail "Unknown option: $1"
      ;;
    *)
      [ -z "$POSITIONAL_TARGET" ] || fail "Only one target path is supported"
      POSITIONAL_TARGET="$1"
      shift
      ;;
  esac
done

if [ "$#" -gt 0 ]; then
  [ -z "$POSITIONAL_TARGET" ] || fail "Only one target path is supported"
  POSITIONAL_TARGET="$1"
  shift
fi

[ "$#" -eq 0 ] || fail "Unexpected extra arguments"

if [ -n "$POSITIONAL_TARGET" ]; then
  TARGET_INPUT="$POSITIONAL_TARGET"
fi

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd -P || printf '')"
SOURCE_ROOT=""
SOURCE_MODE="remote"
SOURCE_BASE_URL="${HARNESS_SOURCE_BASE_URL:-https://raw.githubusercontent.com/hieunm599/repository-harness/vi}"
SOURCE_BASE_URL="${SOURCE_BASE_URL%/}"
CORE_SOURCE_BASE_URL="${HARNESS_CORE_SOURCE_BASE_URL:-https://raw.githubusercontent.com/hieunm599/repository-harness/vi}"
CORE_SOURCE_BASE_URL="${CORE_SOURCE_BASE_URL%/}"
PAYLOAD_MANIFEST="scripts/harness-install-files.txt"
ENGINEERING_WISDOM_PAYLOAD_MANIFEST="scripts/engineering-wisdom-install-files.txt"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../AGENTS.md" ] && [ -f "$SCRIPT_DIR/../harness-docs/HARNESS.md" ]; then
  SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
  SOURCE_MODE="local"
fi

if [ "$YES" -eq 0 ] && can_prompt; then
  prompt_tty "Install Harness v0 into [$TARGET_INPUT]: "
  REPLY_TARGET="$(read_tty)"
  if [ -n "$REPLY_TARGET" ]; then
    TARGET_INPUT="$REPLY_TARGET"
  fi
fi

TARGET_DIR="$(make_absolute_parent "$(expand_path "$TARGET_INPUT")")"
BACKUP_DIR="$TARGET_DIR/.harness-backup/$(date +%Y%m%d%H%M%S)"
CREATED=0
UPDATED=0
SKIPPED=0
CONFLICT_ACTION="install"

if [ "$DRY_RUN" -eq 1 ]; then
  log "Dry run: no files will be written."
elif [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

if [ ! -d "$TARGET_DIR" ]; then
  [ "$DRY_RUN" -eq 1 ] || fail "Target directory could not be created: $TARGET_DIR"
  log "Target directory would be created: $TARGET_DIR"
fi

if [ -d "$TARGET_DIR" ]; then
  [ -w "$TARGET_DIR" ] || fail "Target directory is not writable: $TARGET_DIR"
else
  [ -w "$(dirname "$TARGET_DIR")" ] || fail "Target parent directory is not writable: $(dirname "$TARGET_DIR")"
fi

if [ -d "$TARGET_DIR" ]; then
  check_protected_target_paths
fi

if [ "$SOURCE_MODE" = "local" ]; then
  log "Harness source: $SOURCE_ROOT"
else
  command -v curl >/dev/null 2>&1 || fail "curl is required for remote installation"
  log "Harness source: $SOURCE_BASE_URL"
fi
log "Harness profile: core"
if [ "$INSTALL_ENGINEERING_WISDOM" -eq 1 ]; then
  log "Engineering wisdom: included (explicit opt-in)"
else
  log "Engineering wisdom: excluded"
fi
log "Target project: $TARGET_DIR"

install_harness_core

install_engineering_wisdom
refresh_agent_shim
write_claude_shim

log ""
log "Done. Created: $CREATED, updated: $UPDATED, skipped: $SKIPPED."

if [ "$SKIPPED" -gt 0 ] && [ "$FORCE" -eq 0 ]; then
  log "Existing files were left untouched. Re-run with --force to overwrite with backups."
fi

if [ "$FORCE" -eq 1 ] && [ "$UPDATED" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  log "Backups were written to: $BACKUP_DIR"
fi
