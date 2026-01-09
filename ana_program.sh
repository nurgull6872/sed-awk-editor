#!/bin/bash

# Arayüzleri içeri aktaran dosyam
source ./arayuzler.sh

# kullanicinin isteğine göre dönen döngüm
while true; do
    MENU=$(whiptail --title "Pardus Metin Editor" --menu "Bir arayuz secin:" 15 60 3 \
        "1" "Grafik Arayuzu (GUI) icin tıklayınız" \
        "2" "Terminal Arayuzu (TUI) icin tıklayınız " \
        "3" "Cikis icin tiklayınız" 3>&1 1>&2 2>&3)
    
    [[ $? -ne 0 || "$MENU" == "3" ]] && exit 0
    
    if [ "$MENU" = "1" ]; then
        calistir_gui
    else
        calistir_tui
    fi
done
