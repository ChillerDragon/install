#!/bin/bash

set -u

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

REQUIRED_GIT_VERSION=2.7.0   # HOMEBREW_MINIMUM_GIT_VERSION in brew.sh in Homebrew/brew

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
# tty_underline="$(tty_escape "4;39")"
# tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
# tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

major_minor() {
  echo "${1%%.*}.$(
    x="${1#*.}"
    echo "${x%%.*}"
  )"
}

version_gt() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -gt "${2#*.}" ]]
}
version_ge() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -ge "${2#*.}" ]]
}
version_lt() {
  [[ "${1%.*}" -lt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -lt "${2#*.}" ]]
}

test_git() {
  if [[ ! -x "$1" ]]
  then
    return 1
  fi

  local git_version_output
  git_version_output="$("$1" --version 2>/dev/null)"
  warn "   version: $("$1" --version)"
  warn "got stdout: ${git_version_output}"
  warn "    wanted: ${REQUIRED_GIT_VERSION}"
  warn "[##*]    got: $(major_minor "${git_version_output##* }")"
  warn "[##*] wanted: $(major_minor "${REQUIRED_GIT_VERSION}")"
  version_ge "$(major_minor "${git_version_output##* }")" "$(major_minor "${REQUIRED_GIT_VERSION}")"
}

test_git "$(command -v git)"

