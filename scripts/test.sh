#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
sclang_bin="${SCLANG:-sclang}"
if [[ -z "${SC_CLASS_LIBRARY:-}" ]]; then
    if [[ -d /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary ]]; then
        SC_CLASS_LIBRARY=/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary
    else
        SC_CLASS_LIBRARY=/usr/share/SuperCollider/SCClassLibrary
    fi
fi
config="$(mktemp "${TMPDIR:-/tmp}/patternarium.XXXXXX")"
trap 'rm -f "$config"' EXIT
# YAML single quotes preserve spaces and backslashes; double embedded quotes.
yaml_quote() { local value="${1//\'/\'\'}"; printf "'%s'" "$value"; }
{
    printf 'includePaths:\n  - '; yaml_quote "$SC_CLASS_LIBRARY"
    printf '\n  - '; yaml_quote "$root/Classes"
    printf '\n  - '; yaml_quote "$root/Tests"
    printf '\nexcludePaths: []\nexcludeDefaultPaths: true\npostInlineWarnings: true\n'
} > "$config"
if [[ "$(uname -s)" == Linux ]]; then
    export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}"
fi
"$sclang_bin" -D -l "$config" "${1:-$root/Tests/run.scd}"
