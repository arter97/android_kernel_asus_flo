#!/bin/bash
git fetch f2fs

find . -not -path '*/\.*' -name '*f2fs*' | grep -v 'update_f2fs\|recovery' | while read f2fs; do rm -rf $f2fs; git checkout f2fs/dev -- $f2fs; done

rm -rf fs/f2fs
git checkout f2fs/dev -- fs/f2fs

git log --oneline f2fs/linux-3.4 | head -1 | awk '{print $1}' | while read patch; do git cherry-pick --no-commit $patch; done
git cherry-pick --no-commit b8e7a7e8abf6a2142467fbc1efd888b3ecd84da4
git cherry-pick --no-commit 9c447addfbc21a67731bfce7096a2d5d8700357c
git cherry-pick --no-commit 446f22135243a3d8f7c4081fccfe68bdbfbba2f3
git status
