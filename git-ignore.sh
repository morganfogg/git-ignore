#!/bin/bash

## Appends generic ignore files to your gitignore. Run without arguments to see a list of valid gitignore files.

set -e

linechar="="

script_dir="$( dirname "$0" )"
target_dir="$( pwd )"
target_file="$target_dir/.gitignore"

# Only aliases that are sufficiently different from their "real" value are included here,
# to avoid cluttering the list. e.g. there's no need to list both "ObjectiveC" and "Objective-C".
aliases_to_print="\
JavaScript
TypeScript
Code
IntelliJ
IDEA
RubyMine
PHPStorm
AppCode
Pycharm
CLion
AndroidStudio
WebStorm
Rider
OSX
Darwin
"

headerize() {
    printf '## %s\n## %s\n\n' "$1" "$(printf "%$(( 77 ))s" | tr ' ' $linechar)"
}

cd "$script_dir"

if [ ! -d gitignore ]; then
    git clone --quiet https://github.com/github/gitignore
    cd gitignore
else
    cd gitignore
    git pull --quiet || true # Don't worry if we can't get the latest version
fi

if [ -z "$*" ]; then
    printf "%s\n%s" "$(find -iname '?*.gitignore' -print0 | xargs -0 basename -s .gitignore)" "$aliases_to_print" | sort | column
    exit
fi

declare -A already_processed;

for file in "$@"; do
    file="$( printf '%s' "$file" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' )"
    original_file="$file"

    # Aliases
    case "$file" in
        'js' | 'javascript' | 'ts' | 'typescript' | 'nodejs')
            file='node' ;;
        'code' | 'vscode' )
            file='visualstudiocode' ;;
        'vs' | 'csharp' | 'c-sharp')
            file='visualstudio' ;;
        'sublime' | 'sublime text' | 'sublimetext')
            file='sublimetext' ;;
        'osx' | 'mac' | 'darwin')
            file='macos' ;;
        'intellij' | 'idea' | 'rubymine' | 'phpstorm' | 'appcode' | 'pycharm' | 'clion' | 'androidstudio' | 'webstorm' | 'rider')
            file='jetbrains' ;;
        'notepad++' | 'npp' | 'n++')
            file='notepadpp' ;;
        'kdevelop' | 'kdev')
            file='kdevelop4' ;;
        'objectivec')
            file='objective-c' ;;
    esac

    ignore_file="$(find -iname "$file.gitignore" -print -quit)"

    if [ $? -eq 0 ] && [ -n "$ignore_file" ]; then
        ignore_for="$( basename "$ignore_file" .gitignore )"

        if [ -n "${already_processed["$ignore_for"]}" ]; then
            continue
        fi

        display_name="$ignore_for"
        if [ "$original_file" != "$file" ]; then
            display_name="$( printf '%s (alias of %s)' "$original_file" "$ignore_for" )"
        fi

        already_processed["$ignore_for"]=1
        if [ ! -f "$target_file" ]; then
            printf '%s\n\n\n\n' "$( headerize 'Project-specific rules (add your own rules here)' )" > "$target_file"
        fi

        headerize "$( printf 'Generic rules for %s' "$ignore_for" )" >> "$target_file"
        cat "$ignore_file" <(printf '\n') >> "$target_file"
        printf 'Added rules for %s\n' "$display_name"

    else
        printf 'No ignore file for "%s" found\n' "$file"
    fi
done
