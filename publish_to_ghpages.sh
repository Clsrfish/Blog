#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo
if [[ ! $? == 0 ]]
then
  echo "Failed to Generating site"
  exit $?
fi

echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "`date`" && cd ..
git push origin gh-pages
rm -rf public
