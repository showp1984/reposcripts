#!/bin/bash
set -e
#automerge github stuff to local repo, Example: CM
#by Dennis Rassmann

BASE_LOCDIR=$( pwd );

BRANCHTOMERGEFROM="cm-11.0"
MANIFEST="https://raw.github.com/IllusionRom/android_platform_manifest/illusion-4.4/default.xml"
USEDREMOTE="ill"

EXTMANIFEST="https://raw.github.com/CyanogenMod/android/${BRANCHTOMERGEFROM}/default.xml"
EXTIGNOREDREMOTE="aosp"
SEARCHFOR="CyanogenMod/"

GITHUB="https://github.com/"
REMOTENAME="gh_remote_to_merge"
ONLYONCE=1;

function mergedata() {
	if [[ ! $ONLYONCE -eq 0 ]]; then
		repo abandon merging_branch
		repo start merging_branch --all
		ONLYONCE=0;
	fi

        echo "-------- Working on PATH: $1 | REPO: $2 | EXTREPO: $3";

        cd "${1}" > /dev/null

	if [[ $( git remote | grep ${REMOTENAME}) == "${REMOTENAME}" ]]; then
		git remote set-url ${REMOTENAME} ${GITHUB}/${3}
	else
		git remote add ${REMOTENAME} ${GITHUB}/${3}
	fi

	git fetch ${REMOTENAME}
	git merge --squash ${REMOTENAME}/${BRANCHTOMERGEFROM}

	cd "$BASE_LOCDIR" > /dev/null
}

i=0;
PATHS=$(curl -s $MANIFEST | grep 'path="' | grep -v '<remote' | grep "remote=\"${USEDREMOTE}\"" | sed 's/^.*path="//' | sed 's/ *" .*//')
for npath in ${PATHS}
do
	RPATH[$i]="$npath";
	i=$(( $i + 1 ));
done


i=0;
REPOS=$(curl -s $MANIFEST | grep 'name="' | grep -v '<remote' | grep "remote=\"${USEDREMOTE}\"" | sed 's/^.*name="//' | sed 's/ *" .*//')
EXTREPOS=$(curl -s $EXTMANIFEST | grep 'name="' | grep -v '<remote' | grep -v "remote=\"${EXTIGNOREDREMOTE}\"" | grep "${SEARCHFOR}" | sed 's/^.*name="//' | sed 's/ *" .*//')
for nrepo in ${REPOS}
do
	REPO[$i]="$nrepo";

	j=0;
	for extnrepo in ${EXTREPOS}
	do
		EXTREPO[$j]="${extnrepo}";
		STRIPPEDVAR=${EXTREPO[$j]#${SEARCHFOR}};
		STRIPPEDVARINT=${REPO[$i]/android_platform_/android_};

		if [[ "${STRIPPEDVARINT}" == "${STRIPPEDVAR}" ]]; then
			#DO STUFF USING ALL THREE VARIABLES HERE
			mergedata "${RPATH[$i]}" "${REPO[$i]}" ${EXTREPO[$j]}
		fi

		j=$(( $j + 1 ));
	done
	i=$(( $i + 1 ));
done
