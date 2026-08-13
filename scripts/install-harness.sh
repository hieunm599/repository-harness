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

read_source_text() {
  local relative_path="$1"
  if [ "$SOURCE_MODE" = "local" ]; then
    [ -f "$SOURCE_ROOT/$relative_path" ] || fail "Missing local source file: $SOURCE_ROOT/$relative_path"
    cat "$SOURCE_ROOT/$relative_path"
  else
    curl -fsSL "$SOURCE_BASE_URL/$relative_path" || fail "Could not download $SOURCE_BASE_URL/$relative_path"
  fi
}

copy_manifest_files() {
  local manifest_rel="$1"
  local manifest_tmp=""

  if [ "$SOURCE_MODE" = "local" ]; then
    [ -f "$SOURCE_ROOT/$manifest_rel" ] || fail "Missing local payload manifest: $SOURCE_ROOT/$manifest_rel"
    manifest_tmp="$SOURCE_ROOT/$manifest_rel"
  else
    manifest_tmp="$(mktemp)"
    curl -fsSL "$SOURCE_BASE_URL/$manifest_rel" -o "$manifest_tmp" || fail "Could not download manifest: $SOURCE_BASE_URL/$manifest_rel"
  fi

  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ""|\#*)
        continue
        ;;
    esac

    local rel_path="$line"
    local dest_file="$TARGET_DIR/$rel_path"
    local dest_dir
    dest_dir="$(dirname "$dest_file")"

    if [ "$CONFLICT_ACTION" = "merge" ] && [ -e "$dest_file" ]; then
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      if [ -e "$dest_file" ]; then
        log "update   $rel_path"
        UPDATED=$((UPDATED + 1))
      else
        log "create   $rel_path"
        CREATED=$((CREATED + 1))
      fi
      continue
    fi

    mkdir -p "$dest_dir"

    if [ -e "$dest_file" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
      cp -p "$dest_file" "$BACKUP_DIR/$rel_path"
      UPDATED=$((UPDATED + 1))
    else
      CREATED=$((CREATED + 1))
    fi

    if [ "$SOURCE_MODE" = "local" ]; then
      cp -p "$SOURCE_ROOT/$rel_path" "$dest_file"
    else
      download_file "$SOURCE_BASE_URL/$rel_path" "$dest_file"
    fi
  done < "$manifest_tmp"

  if [ "$SOURCE_MODE" != "local" ]; then
    rm -f "$manifest_tmp"
  fi
}

download_file() {
  local url="$1"
  local target="$2"
  curl -fsSL "$url" -o "$target" || fail "Could not download $url"
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

detect_core_platform() {
  if [ -n "${HARNESS_CORE_PLATFORM:-}" ]; then
    printf '%s\n' "$HARNESS_CORE_PLATFORM"
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

install_harness_core() {
  CORE_PLATFORM="$(detect_core_platform)"
  CORE_BINARY_NAME="harness-$CORE_PLATFORM"
  CORE_STAGE_ROOT="$(mktemp -d)"
  CORE_STAGED_BINARY="$CORE_STAGE_ROOT/$CORE_BINARY_NAME"

  if [ -n "${HARNESS_CORE_BINARY:-}" ]; then
    [ -x "$HARNESS_CORE_BINARY" ] || fail "HARNESS_CORE_BINARY is not executable: $HARNESS_CORE_BINARY"
    cp "$HARNESS_CORE_BINARY" "$CORE_STAGED_BINARY"
    chmod 755 "$CORE_STAGED_BINARY"
  else
    local release_tag
    release_tag="$(read_harness_release_tag)"
    if [ "$release_tag" = "latest" ]; then
      local tag_tmp
      tag_tmp="$(mktemp)"
      if curl -fsSL "$CORE_SOURCE_BASE_URL/scripts/harness-release-tag" -o "$tag_tmp" 2>/dev/null; then
        release_tag="$(awk 'NF && $1 !~ /^#/ { print $1; exit }' "$tag_tmp")"
      fi
      rm -f "$tag_tmp"
    fi
    [[ "$release_tag" =~ ^harness-v[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9]+)*$ ]] ||
      fail "invalid Harness core release tag: $release_tag"
    base_url="${HARNESS_CORE_CLI_BASE_URL:-https://github.com/hieunm599/repository-harness/releases/download/$release_tag}"
    binary_url="${base_url%/}/$CORE_BINARY_NAME"
    checksum_url="$binary_url.sha256"
    checksum_tmp="$CORE_STAGE_ROOT/$CORE_BINARY_NAME.sha256"

    download_file "$checksum_url" "$checksum_tmp"
    download_file "$binary_url" "$CORE_STAGED_BINARY"
    chmod 755 "$CORE_STAGED_BINARY"

    local expected_hash actual_hash
    expected_hash="$(awk '{print $1}' "$checksum_tmp")"
    if command -v shasum >/dev/null 2>&1; then
      actual_hash="$(shasum -a 256 "$CORE_STAGED_BINARY" | awk '{print $1}')"
    elif command -v sha256sum >/dev/null 2>&1; then
      actual_hash="$(sha256sum "$CORE_STAGED_BINARY" | awk '{print $1}')"
    else
      fail "shasum or sha256sum is required to verify the Harness maintenance binary"
    fi

    [ "$expected_hash" = "$actual_hash" ] ||
      fail "checksum verification failed for $CORE_BINARY_NAME (expected $expected_hash, got $actual_hash)"
  fi

  dispatch_core_lifecycle "install"
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

refresh_agent_shim() {
  local dest="$TARGET_DIR/AGENTS.md"
  local block_file
  block_file="$(mktemp)"
  read_source_text "scripts/agent-harness-block.md" > "$block_file"
  local new_block
  new_block="$(cat "$block_file")"
  rm -f "$block_file"

  if [ ! -f "$dest" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      log "create   AGENTS.md"
      CREATED=$((CREATED + 1))
      return 0
    fi
    mkdir -p "$(dirname "$dest")"
    {
      printf '# Agent Instructions\n\n'
      printf 'Add project-specific agent instructions here.\n\n'
      printf '%s\n' "$new_block"
    } > "$dest"
    CREATED=$((CREATED + 1))
    log "created  AGENTS.md"
    return 0
  fi

  local current_content
  current_content="$(cat "$dest")"

  if ! printf '%s\n' "$current_content" | grep -Fq '<!-- HARNESS:BEGIN -->'; then
    if [ "$REFRESH_AGENT_SHIM" -eq 0 ] && [ "$CONFLICT_ACTION" = "merge" ]; then
      SKIPPED=$((SKIPPED + 1))
      return 0
    fi
  fi

  local refreshed_content
  if printf '%s\n' "$current_content" | grep -Fq '<!-- HARNESS:BEGIN -->'; then
    refreshed_content="$(printf '%s\n' "$current_content" | awk -v block="$new_block" '
      /<!-- HARNESS:BEGIN -->/ { print block; in_block=1; next }
      /<!-- HARNESS:END -->/ { in_block=0; next }
      !in_block { print }
    ')"
  else
    refreshed_content="$(printf '%s\n\n%s\n' "$current_content" "$new_block")"
  fi

  if [ "$current_content" = "$refreshed_content" ]; then
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "update   AGENTS.md (shim refreshed)"
    UPDATED=$((UPDATED + 1))
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
  cp -p "$dest" "$BACKUP_DIR/AGENTS.md"
  printf '%s\n' "$refreshed_content" > "$dest"
  UPDATED=$((UPDATED + 1))
  log "updated  AGENTS.md (shim refreshed)"
}

write_claude_shim() {
  [ "$INSTALL_CLAUDE_SHIM" -eq 1 ] || return 0

  local dest="$TARGET_DIR/CLAUDE.md"
  local block_file
  block_file="$(mktemp)"
  read_source_text "scripts/claude-harness-block.md" > "$block_file"
  local new_block
  new_block="$(cat "$block_file")"
  rm -f "$block_file"

  if [ ! -f "$dest" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      log "create   CLAUDE.md"
      CREATED=$((CREATED + 1))
      return 0
    fi
    mkdir -p "$(dirname "$dest")"
    {
      printf '# Project Rules\n\n'
      printf '%s\n' "$new_block"
    } > "$dest"
    CREATED=$((CREATED + 1))
    log "created  CLAUDE.md"
    return 0
  fi

  local current_content
  current_content="$(cat "$dest")"
  local refreshed_content

  if printf '%s\n' "$current_content" | grep -Fq '<!-- HARNESS:BEGIN -->'; then
    refreshed_content="$(printf '%s\n' "$current_content" | awk -v block="$new_block" '
      /<!-- HARNESS:BEGIN -->/ { print block; in_block=1; next }
      /<!-- HARNESS:END -->/ { in_block=0; next }
      !in_block { print }
    ')"
  else
    refreshed_content="$(printf '%s\n\n%s\n' "$current_content" "$new_block")"
  fi

  if [ "$current_content" = "$refreshed_content" ]; then
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "update   CLAUDE.md (shim refreshed)"
    UPDATED=$((UPDATED + 1))
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
  cp -p "$dest" "$BACKUP_DIR/CLAUDE.md"
  printf '%s\n' "$refreshed_content" > "$dest"
  UPDATED=$((UPDATED + 1))
  log "updated  CLAUDE.md (shim refreshed)"
}

dispatch_core_lifecycle() {
  local command="$1"
  local binary_target="$TARGET_DIR/scripts/bin/harness"
  local binary_temp=""
  local runner="$CORE_STAGED_BINARY"
  local args=("$command" "--directory" "$TARGET_DIR")

  if [ "$DRY_RUN" -eq 1 ]; then
    args+=("--dry-run")
  fi
  if [ "$FORCE" -eq 1 ]; then
    args+=("--force")
  fi
  if [ "$CONFLICT_ACTION" = "merge" ]; then
    args+=("--merge")
  fi
  if [ "$CONFLICT_ACTION" = "override" ]; then
    args+=("--override")
  fi

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$TARGET_DIR/scripts/bin"
    binary_temp="$(mktemp "$TARGET_DIR/scripts/bin/harness.tmp.XXXXXX")"
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
