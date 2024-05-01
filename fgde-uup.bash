#!/bin/bash

# Standardwert für die Spracheinstellung
LANGUAGE="de"

# Funktion zum Ändern der Sprache
change_language() {
    local lang=$(dialog --clear \
                        --nocancel \
                        --stdout \
                        --no-lines \
                        --backtitle "Fast Guides DE Ubuntu Updater => www.youtube.com/@Fast-Guides" \
                        --title "Spracheinstellungen" \
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

    # Fehlermeldungen in der entsprechenden Sprache setzen
    set_error_messages

    # Überprüfe, ob das Dialog-Paket installiert ist
    check_dialog_installed
}

# Funktion zum Setzen von Fehlermeldungen in der entsprechenden Sprache
set_error_messages() {
    if [ "$LANGUAGE" = "de" ]; then
        DIALOG_NOT_INSTALLED="Dialog-Paket ist nicht installiert."
        DIALOG_REQUIRED="Das Dialog-Paket wird benötigt, um dieses Skript auszuführen."
    elif [ "$LANGUAGE" = "en" ]; then
        DIALOG_NOT_INSTALLED="Dialog package is not installed."
        DIALOG_REQUIRED="The Dialog package is required to run this script."
    elif [ "$LANGUAGE" = "tr" ]; then
        DIALOG_NOT_INSTALLED="Dialog paketi kurulu değil."
        DIALOG_REQUIRED="Bu betiği çalıştırmak için Dialog paketi gereklidir."
    fi
}

# Funktion zur Überprüfung, ob das Dialog-Paket installiert ist
check_dialog_installed() {
    if ! command -v dialog &> /dev/null; then
        local install_dialog=""
        case "$LANGUAGE" in
            "de") 
                echo "$DIALOG_NOT_INSTALLED"
                read -p "Dialog nich installiert. Möchten Sie es jetzt installieren? (j/n): " install_dialog
                ;;
            "en")
                echo "$DIALOG_NOT_INSTALLED"
                read -p "Dialog not installed. Would you like to install it now? (y/n): " install_dialog
                ;;
            "tr")
                echo "$DIALOG_NOT_INSTALLED"
                read -p "Dialog paketi kurulu değil. Şimdi yüklemek ister misiniz? (e/h): " install_dialog
                ;;
            *)
                echo "$DIALOG_NOT_INSTALLED"
                read -p "Dialog not installed. Would you like to install it now? (y/n): " install_dialog
                ;;
        esac

        if [ "$install_dialog" = "j" ] || [ "$install_dialog" = "y" ] || [ "$install_dialog" = "e" ]  ; then
            sudo apt install dialog
        else
            echo "$DIALOG_REQUIRED"
            exit 1
        fi
    fi
}

# Überprüfe die Befehlszeilenargumente für die Spracheinstellung
if [ "$1" == "-l" ]; then
    case "$2" in
        "de"|"en"|"tr") LANGUAGE="$2" ;;
        *) echo "Invalid Option. Supported Options are : -l de, -l en, -l tr." && exit 1 ;;
    esac
fi

# Überprüfe, ob das Dialog-Paket installiert ist, bevor das Menü angezeigt wird
check_dialog_installed

# Funktion zum Anzeigen des Menüs und Verarbeiten der Benutzereingabe
show_menu() {
    while true; do
        local menu_title=""
        local menu_options=()

        if [ "$LANGUAGE" = "de" ]; then
            menu_title="Ubuntu Update Menü"
            menu_options=("1" "Deb-Pakete aktualisieren"
                           "2" "Flatpaks aktualisieren"
                           "3" "Snap-Pakete aktualisieren"
                           "4" "Alle aktualisieren"
                           "5" "Unnötige Deb-Pakete entfernen"
                           "6" "Deb-Pakete reparieren"
                           "7" "Deb-Cache leeren"
                           "8" "Flatpak-Cache leeren"
                           "9" "Snap-Cache leeren"
                           "10" "Beenden")
        elif [ "$LANGUAGE" = "en" ]; then
            menu_title="Ubuntu Update Menu"
            menu_options=("1" "Update Deb packages"
                           "2" "Update Flatpaks"
                           "3" "Update Snap packages"
                           "4" "Update all"
                           "5" "Remove unnecessary Deb packages"
                           "6" "Repair Deb packages"
                           "7" "Clean Deb cache"
                           "8" "Clean Flatpak cache"
                           "9" "Clean Snap cache"
                           "10" "Exit")
        elif [ "$LANGUAGE" = "tr" ]; then
            menu_title="Ubuntu güncelleme menüsü"
            menu_options=("1" "Deb paketlerini güncelle"
                           "2" "Flatpakları güncelle"
                           "3" "Snap paketlerini güncelle"
                           "4" "Hepsini güncelle"
                           "5" "Gereksiz Deb paketlerini kaldır"
                           "6" "Deb paketlerini onar"
                           "7" "Deb önbelleğini temizle"
                           "8" "Flatpak önbelleğini temizle"
                           "9" "Snap önbelleğini temizle"
                           "10" "Çıkış")
        fi

        local selection=$(dialog --clear \
                                 --nocancel \
                                 --stdout \
                                 --no-lines \
                                 --backtitle "Fast Guides DE Ubuntu Updater => www.youtube.com/@Fast-Guides " \
                                 --title "$menu_title" \
                                 --menu " " \
                                 17 60 1 \
                                 "${menu_options[@]}")

        case "$selection" in
            "1") update_deb_packages;;
            "2") update_flatpaks;;
            "3") update_snap_packages;;
            "4") update_all_packages;;
            "5") autoremove_deb_packages;;
            "6") configure_deb_packages;;
            "7") clean_deb_cache;;
            "8") clean_flatpak_cache;;
            "9") clean_snap_cache;;
            "10") exit ;;
        esac
    done
}

# Funktion zum Aktualisieren der Deb-Pakete
update_deb_packages() {
    clear && check_deb_support
    
    # Lokalisierte Fehlermeldungen
    local error_msg_de="Fehler beim Aktualisieren der Paketliste. Bitte überprüfen Sie Ihre Internetverbindung oder Ihre Paketquellen."
    local error_msg_en="Error updating package list. Please check your internet connection or your package sources."
    local error_msg_tr="Paket listesi güncellenirken hata oluştu. Lütfen internet bağlantınızı veya paket kaynaklarınızı kontrol edin."

    # Führe 'sudo apt update' aus und überprüfe auf Fehler
    if sudo apt update; then
        # Überprüfe, ob Aktualisierungen verfügbar sind
        if [[ $(apt list --upgradable 2>/dev/null | grep -c '^') -gt 1 ]]; then
            sudo apt upgrade
        else
            case "$LANGUAGE" in
                "de") echo "Es sind keine Aktualisierungen verfügbar." ;;
                "en") echo "No updates available." ;;
                "tr") echo "Yeni güncelleme yok." ;;
            esac
        fi
    else
        # Gib die Fehlermeldung entsprechend der gewählten Sprache aus
        case "$LANGUAGE" in
            "de") echo "$error_msg_de" ;;
            "en") echo "$error_msg_en" ;;
            "tr") echo "$error_msg_tr" ;;
        esac
    fi

    sleep 2
}

# Funktion zum Aktualisieren der Flatpaks
update_flatpaks() {
    clear && check_flatpak_installed && flatpak update -y && sleep 2
}

# Funktion zum Aktualisieren der Snap-Pakete
update_snap_packages() {
    clear && check_snap_installed && snap refresh && sleep 2
}

# Funktion zum Aktualisieren aller Pakete
update_all_packages() {
    clear && update_deb_packages && update_flatpaks && update_snap_packages
}

# Funktion zum Entfernen unnötiger Deb-Pakete
autoremove_deb_packages() {
    clear && check_deb_support && sudo apt autoremove && sleep 2
}

# Funktion zum Reparieren von Deb-Paketen
configure_deb_packages() {
    clear && check_deb_support && sudo dpkg --configure -a && sleep 2 && sudo apt upgrade && sleep 2 && sudo apt update -y && sleep 2
}

# Funktion zum Leeren des Deb-Cache
clean_deb_cache() {
    clear && check_deb_support && sudo apt-get autoclean && sleep 2
}

# Funktion zum Leeren des Flatpak-Cache
clean_flatpak_cache() {
    clear && check_flatpak_installed && sudo flatpak uninstall --unused -y && sleep 2 && sudo rm -rfv /var/tmp/flatpak-cache-* && sleep 2
}

# Funktion zum Leeren des Snap-Cache
clean_snap_cache() {
    clear && check_snap_installed

    case "$LANGUAGE" in
        "de") message="Dateien im /var/lib/snapd/cache werden gelöscht" ;;
        "en") message="Files in /var/lib/snapd/cache will be deleted" ;;
        "tr") message="/var/lib/snapd/cache içindeki dosyalar silinecek" ;;
        *) message="Files in /var/lib/snapd/cache will be deleted" ;;
    esac
	clear && check_snap_installed && echo "$message" && sleep 2 && sudo find /var/lib/snapd/cache/ -exec rm -v {} \;
}


# Funktion zur Überprüfung, ob Deb-Pakete unterstützt werden
check_deb_support() {
    if ! command -v apt &> /dev/null; then
        case "$LANGUAGE" in
            "de") echo "Das System unterstützt keine Deb-Pakete." ;;
            "en") echo "The system does not support Deb packages." ;;
            "tr") echo "Sistem Deb paketlerini desteklemiyor." ;;
            *) echo "The system does not support Deb packages." ;;
        esac
        exit 1
    fi
}

# Funktion zur Überprüfung, ob Flatpak installiert ist
check_flatpak_installed() {
    if ! command -v flatpak &> /dev/null; then
        case "$LANGUAGE" in
            "de") echo "Flatpak ist auf diesem System nicht installiert." ;;
            "en") echo "Flatpak is not installed on this system." ;;
            "tr") echo "Bu sistemde Flatpak kurulu değil." ;;
            *) echo "Flatpak is not installed on this system." ;;
        esac
    fi
}

# Funktion zur Überprüfung, ob Snap installiert ist
check_snap_installed() {
    if ! command -v snap &> /dev/null; then
        case "$LANGUAGE" in
            "de") echo "Snap ist auf diesem System nicht installiert." ;;
            "en") echo "Snap is not installed on this system." ;;
            "tr") echo "Bu sistemde Snap kurulu değil." ;;
            *) echo "Snap is not installed on this system." ;;
        esac        
    fi
}

# Setze Fehlermeldungen in der entsprechenden Sprache
set_error_messages

# Überprüfe, ob die Funktion change_language aufgerufen werden soll
if [ "$#" -eq 0 ]; then
    change_language
fi

# Funktion zum Anzeigen des Menüs und Verarbeiten der Benutzereingabe
show_menu
