#!/usr/bin/env bash
#
# Copyright (c) STMicroelectronics 2014
#
# This file is part of repo-mirror.
#
# repo-mirror is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License v2.0
# as published by the Free Software Foundation
#
# repo-mirror is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# v2.0 along with repo-mirror. If not, see <http://www.gnu.org/licenses/>.
#

# unitary test

source `dirname $0`/common.sh

TEST_CASE="repo-mirror repo mirror sequential aliased git repo test"

# Skip python 3 not supported by repo 1
! is_python3_repo1 || skip "python 3 not supported by repo 1"

# Generate a repo/git structure with a project1.git
$SRCDIR/tests/scripts/generate_repo.sh repos-1 project1

# Generate another repo/git structure with also a project1.git,
# hence will generate an aliased repo in the mirrors
$SRCDIR/tests/scripts/generate_repo.sh repos-2 project1

# Repo init/sync first repo tree with repo-mirror, creating a mirror for project1.git
mkdir -p repo-mirrors
mkdir -p test-repos-1
pushd test-repos-1 >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos-1/manifests.git </dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync
[ -f project1/README ]

# Verify that local project1 have an alternate pointing to default mirror
# and that the HEAD commit object is not local and is in the alternate
[ -f project1/.git/objects/info/alternates ]
[ "$(<project1/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project1.git/objects" ]
obj1=$(env GIT_DIR=project1/.git git rev-parse HEAD)
[ ! -f project1/.git/objects/${obj1::2}/${obj1:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj1::2}/${obj1:2} ]
popd >/dev/null

# Repo init/sync second repo tree with repo-mirror, creating a mirror for project1.git at the same place as
# the previous project
# Actually this is ok (at least sequentially), but a warning "no common commits" can be generated by git.
mkdir -p test-repos-2
pushd test-repos-2 >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos-2/manifests.git </dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync
[ -f project1/README ]

# Verify that local project1 have an alternate pointing to default mirror
# and that the HEAD commit object is not local and is in the alternate
[ -f project1/.git/objects/info/alternates ]
[ "$(<project1/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project1.git/objects" ]
obj2=$(env GIT_DIR=project1/.git git rev-parse HEAD)
[ ! -f project1/.git/objects/${obj2::2}/${obj2:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj2::2}/${obj2:2} ]

# Check if the previous object from the aliased repo is still there also
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj1::2}/${obj1:2} ]

popd >/dev/null

# Check if a new init/sync for the first repo tree still works
rm -rf test-repos-1
mkdir -p test-repos-1
pushd test-repos-1 >/dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- init -u file://"$TMPTEST"/repos-1/manifests.git </dev/null
$REPO_MIRROR -m "$TMPTEST/repo-mirrors" -d -q -- sync
[ -f project1/README ]

# Verify that local project1 have an alternate pointing to default mirror
# and that the HEAD commit object is not local and is in the alternate
[ -f project1/.git/objects/info/alternates ]
[ "$(<project1/.git/objects/info/alternates)" = "$TMPTEST/repo-mirrors/default/repos/project1.git/objects" ]
obj1=$(env GIT_DIR=project1/.git git rev-parse HEAD)
[ ! -f project1/.git/objects/${obj1::2}/${obj1:2} ]
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj1::2}/${obj1:2} ]

# Check if the previous object from the aliased repo is still there also
[ -f "$TMPTEST"/repo-mirrors/default/repos/project1.git/objects/${obj2::2}/${obj2:2} ]

popd >/dev/null
