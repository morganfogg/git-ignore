# git-ignore.sh

Pulls Gitignore files from https://github.com/github/gitignore and adds them to your repository. Run without arguments to see a list of available gitignores.

## Setup

```bash
git clone https://github.com/morganfogg/git-ignore
git config --global alias.ignore "!$PWD/git-ignore/git-ignore.sh"
```

## Example Usage

```bash
git ignore java eclipse netbeans intellij
```
