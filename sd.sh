#!/bin/bash

#Exécution: ./sd.sh [paramètres]
#Objectifs: Affiche un tableau contenant le système de fichiers, l'espace utilisé, l'espace disponible, le pourcentage d'espace utilisé et le point de montage de partitions
#Prérequis: Aucun


#Menu help
if [ "$1" = "--help" ]; then
	printf  "\033[1;96mExécution:\033[0m\n  sd.sh [parametres]\n"
	printf "\033[1;96mAffiche un tableau contenant:\033[0m\n"
	printf	"  le système de fichiers\n  l'espace utilisé\n  l'espace disponible\n  le pourcentage d'espace utilisé\n  le point de montage des partitions\n"
	printf "\033[1;96mPrérequis:\033[0m \n  Aucun\n\033[1m "
	exit 0

fi


nom=($(lsblk -p | grep "─/dev/sd"|tr -d "─├└" | awk '{print $1}'))

declare -A taille
cmpt=0
for tai in $(lsblk -p |grep "─/dev/sd"|tr -d "─├└" | awk '{print $4}'); do
	taille+=([${nom[$cmpt]}]=$tai)
	((cmpt+=1))
done

declare -A monte
cmpt=0

#point de montage( - si non monté)
for point in $(lsblk -p |grep "─/dev/sd"| awk '{print ($7!="" ? $7:"-")}'
); do
	monte+=([${nom[$cmpt]}]=$point)
	((cmpt+=1))
done

#utilisée=$3 dispo=$4 pourcentage=$5
cTmp=0
declare -A used
declare -A dispo
declare -A prcnt
while [[ $cTmp -lt $cmpt ]]; do
	prt=${nom[$cTmp]}

	#si la partition n'est pas montée
	if ! df -h $prt | awk '{print $1}' | grep 'sd' >/dev/null 2>&1  ; then
		used+=([$prt]=0)
		dispo+=([$prt]=${taille[$prt]})
		prcnt+=([$prt]='0%')
	else
		used+=([$prt]=$(df -h $prt | grep 'sd'| awk '{print $3}'))
		dispo+=([$prt]=$(df -h $prt | grep 'sd'| awk '{print $4}'))
		prcnt+=([$prt]=$(df -h $prt | grep 'sd'| awk '{print $5}'))
	fi
	((cTmp+=1))
done


#Affichage du nom des colonnes
printf "\033[1;31m%-15s\033[0m | \033[1;97m%-5s\033[0m  | \033[1;32m%-5s\033[0m | \033[1;35m%-5s\033[0m | \033[1;93m%-10s\033[0m | \033[1;96m%-10s\033[0m\n" "Sys. de fichiers" "Taille" "Utilisé" "Dispo" "Utilisé%" "Monté sur"

cTmp=0

#affichage des répertoires et leurs informations
while [[ $cTmp -lt $cmpt ]]; do

        prt=${nom[$cTmp]}
	printf "\033[1;97m%-16s\033[0m | \033[1;97m%-7s\033[0m | \033[1;97m%-7s\033[0m | \033[1;97m%-5s\033[0m | \033[1;97m%-9s\033[0m | \033[1;97m%-15s\033[0m\n" "$prt" "${taille[$prt]}" "${used[$prt]}" "${dispo[$prt]}" "${prcnt[$prt]}" "${monte[$prt]}"
	
	((cTmp+=1))
done
exit 0
