#!/bin/bash

# affiche tous les dossiers contenant le dossier @eaDir
#find /volume1/video/Films/ -type d -name '@eaDir' | sed -r 's|/[^/]+$||' |sort |uniq

# supprime tous les dossiers vide
#find /volume1/video/Films/ -type d -empty -delete

# affiche le nombre de fichier dans le dossier
#find . -maxdepth 1 -type d -exec bash -c "echo -ne '{} '; ls '{}' | wc -l" \;


find /volume1/video/Films/ -type d -name '@eaDir' | sed -r 's|/[^/]+$||' | while read i;
	do
		if [[ "$(ls "$i" | wc -l)" -eq "1" ]];
			then
				echo "on peu supp : $i"
				#rm -rf "$i/@eaDir"
				#rmdir "$i"
		fi
	done
