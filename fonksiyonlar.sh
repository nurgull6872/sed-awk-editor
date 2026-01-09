#!/bin/bash

# Dosya isimlendirmesini işlem türüne göre güncelleyen fonksiyon
isim_guncelle() {
    local dosya="$1"
    local ek="$2"
    local base="${dosya%.*}"
    local ext="${dosya##*.}"
    if [[ "$base" == *"_ISLEM_"* ]]; then
        echo "${base}_${ek}.${ext}"
    else
        echo "${base}_ISLEM_${ek}.${ext}"
    fi
}

# Sed için özel karakterleri güvenli hale getirir
guvenli_sed() {
    # Hem / hem & hem de . gibi karakterleri kaçırır
    printf '%s\n' "$1" | sed 's/[[\.*^$(){}?+|/&]/\\&/g'
}

# Kayıt sırasında varsa eski dosyanın yedeğini (.bak) alır
yedekle_ve_kaydet() {
    local kaynak="$1"
    local hedef="$2"
    if [[ -f "$hedef" ]]; then
        cp "$hedef" "${hedef}.bak"
    fi
    cp "$kaynak" "$hedef"
}

# Grafik arayüzünde kullanıcıya Bash komutunu gösterir
ogret_gui() {
    local cmd="$1"
    local desc="$2"

    # Değişken isimlerinden Türkçe karakteri (ü) kaldırdık
    local safe_desc=$(echo "$desc" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    local safe_cmd=$(echo "$cmd" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    yad --title="Bash Komut Bilgisi" \
        --text="<b>Calisacak Komut:</b>\n<span font='Monospace 10'>$safe_cmd</span>\n\n<b>Aciklama:</b>\n$safe_desc" \
        --width=450 --center --button="Tamam:0" --image="help-about"
}

# Terminal arayüzünde kullanıcıya Bash komutunu gösterir
ogret_tui() {
    local cmd="$1"
    local desc="$2"
    whiptail --title "Bash Komut Bilgisi" --msgbox "KOMUT:\n$cmd\n\nAÇIKLAMA:\n$desc" 15 60
}