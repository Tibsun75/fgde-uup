#!/bin/bash

# Standardwert für die Spracheinstellung
LANGUAGE="de"

# Funktion zum Ändern der Sprache
change_language() {
    local lang=$(dialog --clear \
                        --nocancel \
                        --stdout \
                        --no-lines \
                        --backtitle "Fast Guides DE Ubuntu Updater => Please visit: www.youtube.com/@Fast-Guides" \
                        --title "Language Settings" \
                        --menu " " \
                        10 40 10 \
                        "de" "Deutsch" \
                        "en" "Englisch" \
                        "tr" "Türkçe"
                        )

    # Setze die Spracheinstellung entsprechend der Auswahl
    case "$lang" in
        "de") LANGUAGE="de" ;;
        "en") LANGUAGE="en" ;;
        "tr") LANGUAGE="tr" ;;
        *) echo "Invalid selection. Please choose a language." && change_language ;;
    esac
}

# Überprüfe die Befehlszeilenargumente für die Spracheinstellung
if [ "$1" == "-l" ]; then
    case "$2" in
        "de"|"en"|"tr") LANGUAGE="$2" ;;
        *) echo "Invalid language option. Supported options are: de, en, tr." && exit 1 ;;
    esac
fi

# Überprüfe, ob das Dialog-Paket installiert ist
if ! command -v dialog &> /dev/null; then
    LANGUAGE="en"  # Ändere die Sprache vorübergehend auf Englisch
    read -p "The dialog package is not installed. Would you like to install it now? (j/n): " answer
    if [ "$answer" = "j" ]; then
        sudo apt install dialog
    elif [ "$answer" = "y" ]; then
        sudo apt install dialog
    elif [ "$answer" = "J" ]; then
        sudo apt install dialog
    elif [ "$answer" = "Y" ]; then
        sudo apt install dialog
    else
        echo ".The Dialog package is required to run this script. The program will end"
        exit 1
    fi
fi

# Funktion zur Überprüfung, ob Deb-Pakete unterstützt werden
check_deb_support() {
    if ! command -v apt &> /dev/null; then
        echo "Das System unterstützt keine Deb-Pakete."
        exit 1
    fi
}

# Funktion zur Überprüfung, ob Flatpak installiert ist
check_flatpak_installed() {
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak ist auf diesem System nicht installiert."
        exit 1
    fi
}

# Funktion zur Überprüfung, ob Snap installiert ist
check_snap_installed() {
    if ! command -v snap &> /dev/null; then
        echo "Snap ist auf diesem System nicht installiert."
        exit 1
    fi
}

# Funktion zur Anzeige des Menüs und Verarbeitung der Benutzereingabe
show_menu() {
    local menu_title=""
    local menu_options=()

    if [ "$LANGUAGE" = "de" ]; then
        menu_title="Ubuntu Update Menü"
        menu_options=("1" "Ubuntu deb Pakete aktualisieren"
                       "2" "Flatpaks aktualisieren"
                       "3" "Snap Pakete aktualisieren"
                       "4" "Alles aktualisieren"
                       "5" "überflüssige deb Pakete löschen mit apt autoremove"
                       "6" "Ubuntu deb Pakete reparieren"
                       "7" "Ubuntu deb cache löschen"
                       "8" "Flatpak cache löschen"
                       "9" "Snap Cache löschen"
                       "10" "Beenden")
    elif [ "$LANGUAGE" = "en" ]; then
        menu_title="Ubuntu Update Menu"
        menu_options=("1" "Update deb Ubuntu packages"
                       	"2" "Update Flatpaks"
                       	"3" "Update Snap packages"
			"4" "Update all"
			"5" "autoremove unnecessary deb packages with apt autoremove"
			"6" "repair deb packages"
			"7" "empty Ubuntu deb cache"
                       	"8" "empty Flatpak cache"
                       	"9" "empty Snap cache"
                       	"10" "Exit")
    elif [ "$LANGUAGE" = "tr" ]; then
        menu_title="Ubuntu günceleme menü"
        menu_options=("1" "Ubuntu deb paketlerini güncelle"
                       	"2" "Flatpakları güncelle"
                       	"3" "Snap paketlerini güncelle"
                       	"4" "Hepsini güncelle"
                       	"5" "Gereksiz deb paketleri kaldır : apt autoremove "
	                "6" "Ubuntu deb paket hataları kaldır"
                       	"7" "Ubuntu deb cache kaldır"
                       	"8" "Flatpak cache kaldır"
                       	"9" "Snap Cache kaldır"
                       	"10" "Çıkış")
    fi

    local selection=$(dialog --clear \
                             --nocancel \
                             --stdout \
                             --no-lines\
                             --backtitle "Fast Guides Ubuntu Updater => www.youtube.com/@Fast-Guides " \
                             --title "$menu_title" \
                             --menu " " \
                             17 60 1 \
                             "${menu_options[@]}")

    case "$selection" in
        "1") clear && check_deb_support && sudo apt update && sleep 3 && sudo apt upgrade -y && sleep 3;;
        "2") clear && check_flatpak_installed && flatpak update -y && sleep 3;;
        "3") clear && check_snap_installed && snap refresh && sleep 3;;
        "4") clear && check_flatpak_installed && check_snap_installed && check_deb_support && sudo apt update && sleep 3 && sudo apt upgrade -y && sleep 3 && flatpak update && sleep 3 && snap refresh && sleep 3;;
        "5") clear && check_deb_support && sudo apt autoremove && sleep 3;;
        "6") clear && check_deb_support && echo "dpkg --configure -a: " && sudo dpkg --configure -a && sleep 3 && sudo apt upgrade && sleep 3 && sudo apt update -y && sleep 3;;
        "7") clear && check_deb_support && echo "sudo apt-get clean" && sudo apt-get clean && sleep 3;;
        "8") clear && check_flatpak_installed && sudo flatpak uninstall --unused -y && sleep 3 && sudo rm -rfv /var/tmp/flatpak-cache-* && sleep 3;;
	"9") clear && check_snap_installed && echo deleting files in "/var/lib/snapd/cache" && sudo sudo find /var/lib/snapd/cache/ -exec rm -v {} \; && sleep 3;;
        "10") clear && exit ;;
    esac
}

# Sprache wählen, falls keine gültigen Befehlszeilenargumente vorhanden sind
if [ "$1" != "-l" ]; then
    change_language
fi

# Hauptfunktionalität des Skripts
while true; do
    # Dialogmenü anzeigen
    show_menu
done
