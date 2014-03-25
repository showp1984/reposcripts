#!/bin/bash
#autocreate & push gerrit repos with manifest content from github
#by Dennis Rassmann

BASE_LOCDIR=$( pwd );
MANIFEST="https://raw.github.com/IllusionRom/android_platform_manifest/illusion-4.4/default.xml"
PORTNR="29418"
USRNAME="gerrituser"
GERRITURL="gerrit.url"
REMOTENAME="remotename-to-push"
IGNOREDREMOTE1="aosp"
IGNOREDREMOTE2="gh"

function pushdata() {
        echo "-------- Working on PATH: $1 | REPO: $2"
        ssh -p ${PORTNR} ${USRNAME}@${GERRITURL} gerrit create-project -n ${2}
        cd "${1}" > /dev/null
	git fetch --all
	git branch -a | grep -v HEAD | perl -ne 'chomp($_); s|^\*?\s*||; if (m|(.+)/(.+)| && not $d{$2}) {print qq(git branch --track $2 $1/$2\n)} else {$d{$_}=1}' | csh -xfs
        git remote add ${REMOTENAME}_gerrit ssh://${USRNAME}@${GERRITURL}:${PORTNR}/${2}
        git push --all -f ${REMOTENAME}_gerrit
        cd "$BASE_LOCDIR" > /dev/null
}

i=0;
PATHS=$(curl -s $MANIFEST | grep 'path="' | grep -v '<remote' | grep -v "${IGNOREDREMOTE1}" | grep -v "${IGNOREDREMOTE2}" | sed 's/^.*path="//' | sed 's/ *" .*//')
for npath in ${PATHS}
do
	RPATH[$i]="$npath";
	i=$(( $i + 1 ));
done


i=0;
REPOS=$(curl -s $MANIFEST | grep 'name="' | grep -v '<remote' | grep -v "${IGNOREDREMOTE1}" | grep -v "${IGNOREDREMOTE2}" | sed 's/^.*name="//' | sed 's/ *" .*//')
for nrepo in ${REPOS}
do
	REPO[$i]="$nrepo";

	#DO STUFF USING BOTH VARIABLES HERE
	pushdata "${RPATH[$i]}" "${REPO[$i]}"

	i=$(( $i + 1 ));
done


