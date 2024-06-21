#!/bin/bash
#get language from OS
get_lang() {
	local lang="${LANG:0:2}"
        local available=("pt" "en")

        if [[ " ${available[*]} " == *"$lang"* ]]; then
        	ulang="$lang"
        else
                ulang="en"
        fi
        }
#languages - add new translations under here
if ulang="pt"; then
	startup () {
		echo "Este é o Popsicle! por Psygreg."
		echo "Este programa irá fazer uma série de otimizações no sistema e adicionar repositórios necessários, convertendo seu Pop!_OS em Popsicle!"
		echo "Deseja prosseguir?"
		}
	usrcancel="Cancelado pelo usuário."
	_ask_xanmod="Agora confira em https://xanmod.org pela versão correta do kernel para o seu processador e selecione:"
	_cancel_xanmod="Pulou a instalação do kernel linux-xanmod."
	sysfail="Sistema não compatível!"
	success="Popsicle! concluído. Reinicie o sistema para aplicar todas as alterações."
else
	startup () {
		echo "This is Popsicle! by Psygreg."
		echo "This program will do a series of system optimizations and add required software repos, converting your Pop!_OS into Popsicle!"
		echo "Proceed?"
		}
	usrcancel="Cancelled by user."
	_ask_xanmod="Now check https://xanmod.org for the correct version of the kernel for your processor and select it:"
	_cancel_xanmod="Skipped linux-xanmod kernel installation."
	sysfail="System not compatible!"
	success="Popsicle! is done. Reboot to apply all changes."
fi
#to deploy Popsicle!
deploy () {
	sudo sed -i 's/WaylandEnable=false/#WaylandEnable=false/' /etc/gdm3/custom.conf
	sudo apt install curl ca-certificates -y
	curl https://repo.waydro.id | sudo bash
	echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | sudo tee /etc/apt/sources.list.d/notion-repackaged.list
	wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /usr/share/keyrings/xanmod-archive-keyring.gpg
	echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list\
	sudo apt update
	sudo apt install plasma-discover plasma-discover-backend-flatpak timeshift waydroid -y;
	sudo apt autoremove libreoffice-math libreoffice-writer libreoffice-impress libreoffice-calc libreoffice-draw pop-shop -y
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak remote-add --if-not-exists --user launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
	flatpak install -y --noninteractive org.gnome.Platform//45
	sudo sed -i 's/PRETTY_NAME="Pop!_OS 22.04 LTS"/PRETTY_NAME="Popsicle! 22.04 LTS"/' /etc/os-release
	}
#for kernel installation
xanmod () {
	echo "$_ask_xanmod"
	select xanmod_ver in "v1" "v2" "v3" "v4" "N"; do
		case $xanmod_ver in
			v1 ) sudo apt install linux-xanmod-x64v1 && echo "$success" && exit 0;;
			v2 ) sudo apt install linux-xanmod-x64v2 && echo "$success" && exit 0;;
			v3 ) sudo apt install linux-xanmod-x64v3 && echo "$success" && exit 0;;
			v4 ) sudo apt install linux-xanmod-x64v4 && echo "$success" && exit 0;;
			N ) echo "$_cancel_xanmod" && exit 0;;
		esac
	done
	}
#program runtime start
get_lang
if grep -q 'NAME="Pop!_OS"' /etc/os-release; then
	startup
	select yn in "Yes" "No"; do
		case $yn in
			Yes )
				deploy;
				xanmod;;
			No ) 
				echo "$usrcancel";
				exit 0;;
		esac
	done
else
	echo "$sysfail"
	exit 1
fi

