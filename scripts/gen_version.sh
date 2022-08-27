#!/bin/bash

git=$(sh /etc/profile; which git)
number_of_commits=$(git log --oneline $(git describe --tags --abbrev=0).. | wc -l)
git_release_version=$("$git" describe --tags --always --abbrev=0)
myString="${myString:1}"

echo "$number_of_commits"
echo "$git_release_version"

target_plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
dsym_plist="$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME/Contents/Info.plist"

for plist in "$target_plist" "$dsym_plist"; do
  if [ -f "$plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $number_of_commits" "$plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${git_release_version#*v}" "$plist"
  fi
done
