#!/usr/bin/env bash
set -euo pipefail

APPLY=false

if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BACKUP_DIR="$REPO_ROOT/.release-cleanup-backup-$(date +%Y%m%d-%H%M%S)"

echo "NutsNews iOS release cleanup"
echo "Repo: $REPO_ROOT"
echo ""

if [[ "$APPLY" == false ]]; then
  echo "Mode: DRY RUN"
  echo "Nothing will be deleted."
  echo ""
else
  echo "Mode: APPLY"
  echo "Backup folder: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  echo ""
fi

delete_path() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    return
  fi

  if [[ "$APPLY" == false ]]; then
    echo "Would remove: $path"
    return
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$path")"
  cp -R "$path" "$BACKUP_DIR/$path"

  if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
    git rm -rf "$path"
  else
    rm -rf "$path"
  fi

  echo "Removed: $path"
}

echo "Cleaning temporary root-level bundle README files..."
echo ""

while IFS= read -r file; do
  base="$(basename "$file")"

  case "$base" in
    README.md|LICENSE|LICENSE.md|.gitignore)
      continue
      ;;
  esac

  if [[ "$base" == *_README.md ]]; then
    delete_path "$base"
  fi
done < <(find . -maxdepth 1 -type f | sed 's#^\./##' | sort)

echo ""
echo "Cleaning macOS junk files..."
echo ""

while IFS= read -r file; do
  clean_path="${file#./}"
  delete_path "$clean_path"
done < <(find . \( -name ".DS_Store" -o -name "._*" \) -type f | sort)

while IFS= read -r dir; do
  clean_path="${dir#./}"
  delete_path "$clean_path"
done < <(find . -name "__MACOSX" -type d | sort)

echo ""
echo "Cleaning local build logs if present..."
echo ""

delete_path "build-logs"

echo ""
echo "Cleaning accidental Xcode project backup files..."
echo ""

while IFS= read -r file; do
  clean_path="${file#./}"
  delete_path "$clean_path"
done < <(find NutsNews -name "*.backup-*" -type f | sort)

echo ""
echo "Done."

if [[ "$APPLY" == false ]]; then
  echo ""
  echo "This was a dry run."
  echo "Run this to actually clean the repo:"
  echo ""
  echo "  ./scripts/cleanup-release-readmes.sh --apply"
else
  echo ""
  echo "Backup saved at:"
  echo "  $BACKUP_DIR"
  echo ""
  echo "Review changes with:"
  echo "  git status"
fi
