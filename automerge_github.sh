#!/bin/bash
set -e
#automerge github stuff to local repo
#by Dennis Rassmann

BASE_LOCDIR=$( pwd );
MANIFEST="https://raw.github.com/IllusionRom/android_platform_manifest/illusion-4.4/default.xml"
USEDREMOTE="gh"
SEARCHFOR="CyanogenMod/"
GITHUB="https://github.com/"
REMOTENAME="gh_remote_to_merge"
BRANCHTOMERGEFROM="cm-11.0"
ONLYONCE=1;

function mergedata() {
        echo "-------- Working on PATH: $1 | REPO: $2"
	if [[ ! $ONLYONCE -eq 0 ]]; then
		repo abandon merging_branch
        repo start merging_branch --all
		ONLYONCE=0;
	fi

        cd "${1}" > /dev/null
	if [[ $( git remote | grep ${REMOTENAME}) == "${REMOTENAME}" ]]; then
		git remote set-url ${REMOTENAME} ${GITHUB}/${2}
	else
		git remote add ${REMOTENAME} ${GITHUB}/${2}
	fi
	git fetch ${REMOTENAME}
	git checkout merging_branch
	git merge ${REMOTENAME}/${BRANCHTOMERGEFROM}
        cd "$BASE_LOCDIR" > /dev/null
}

i=0;
PATHS=$(curl -s $MANIFEST | grep "${SEARCHFOR}" | grep 'path="' | grep -v '<remote' | grep "remote=\"${USEDREMOTE}\"" | sed 's/^.*path="//' | sed 's/ *" .*//')
for npath in ${PATHS}
do
	RPATH[$i]="$npath";
	i=$(( $i + 1 ));
done


i=0;
REPOS=$(curl -s $MANIFEST | grep "${SEARCHFOR}" | grep 'name="' | grep -v '<remote' | grep "remote=\"${USEDREMOTE}\"" | sed 's/^.*name="//' | sed 's/ *" .*//')
for nrepo in ${REPOS}
do
	REPO[$i]="$nrepo";

	#DO STUFF USING BOTH VARIABLES HERE
	mergedata "${RPATH[$i]}" "${REPO[$i]}"

	i=$(( $i + 1 ));
done