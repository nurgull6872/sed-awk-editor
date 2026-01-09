#!/bin/bash

# Fonksiyonları içeri aktar
source ./fonksiyonlar.sh

# GUI 
calistir_gui() {
    while true; do
        ORJINAL_DOSYA=$(yad --title="Dosya Sec" --file --center --width=500 \
            --text="Uzerinde calismak istediginiz dosyayi secin")
        [[ -z "$ORJINAL_DOSYA" || ! -f "$ORJINAL_DOSYA" ]] && break

        GECICI_DOSYA=$(mktemp)
        cp "$ORJINAL_DOSYA" "$GECICI_DOSYA"
        YENI_ISIM="$ORJINAL_DOSYA"

        while true; do
            ISLEM=$(yad --title="Pardus Editor (GUI)" --list \
                --column="No" --column="Yapilacak Islem" \
                1 "Metin Icinde Kelime Degistir" \
                2 "Bos Satirlari Temizle" \
                3 "Belirli Bir Satiri Sil" \
                4 "Satir Numarasi Ekle" \
                5 "Belirli Bir Sutunu Ayikla" \
                6 "Sarta Gore Filtrele (Sutun X > Sayi Y)" \
                7 "Sutun Toplami Hesapla" \
                8 "Dosya Icerigine Goz At" \
                9 "Kaydet ve Yeni Dosya Sec" \
                --button="Geri Don:1" --button="Uygula:0" \
                --center --width=550 --height=500)
            
            [[ $? -eq 1 || -z "$ISLEM" ]] && { rm -f "$GECICI_DOSYA"; break 2; }
            SECIM=$(echo $ISLEM | cut -d'|' -f1)
            
            if [[ "$SECIM" == "9" ]]; then
                KAYIT_ISMI=$(yad --entry --title="Dosyayi Kaydet" --text="Kaydedilecek dosya ismini girin:\n(Varsa eski dosya .bak olarak yedeklenir)" --entry-text="$YENI_ISIM" --center --width=400)
                if [[ -n "$KAYIT_ISMI" ]]; then
                    yedekle_ve_kaydet "$GECICI_DOSYA" "$KAYIT_ISMI"
                    yad --info --text="Dosya Kaydedildi ve Yedek Alindi (varsa): $KAYIT_ISMI" --center
                fi
                rm -f "$GECICI_DOSYA"; break
            fi

            STEP_FILE=$(mktemp)
            case $SECIM in
                1)
                    VERI=$(yad --form --title="Kelime Degistir" --field="Eski Kelime" --field="Yeni Kelime" --center)
                    [[ -z "$VERI" ]] && { rm -f "$STEP_FILE"; continue; }
                    ESKI=$(echo $VERI | cut -d'|' -f1); YENI=$(echo $VERI | cut -d'|' -f2)
                    ESKI_ESC=$(guvenli_sed "$ESKI"); YENI_ESC=$(guvenli_sed "$YENI")
                    ogret_gui "sed 's/$ESKI_ESC/$YENI_ESC/g'" "Kullanicinin girdigi özel karakterleri (\, /, &) etkisizlestirerek güvenli degisim yapar."
                    sed "s/$ESKI_ESC/$YENI_ESC/g" "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "guncel")
                    ;;
                2)
                    ogret_gui "sed '/^[[:space:]]*$/d'" "Bos ve sadece bosluk iceren satirlari siler."
                    sed '/^[[:space:]]*$/d' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "temiz")
                    ;;
                3)
                    SATIR=$(yad --entry --title="Satir Sil" --text="Silinecek Satir No:" --center)
                    [[ -z "$SATIR" ]] && { rm -f "$STEP_FILE"; continue; }
                    ogret_gui "sed '${SATIR}d'" "Belirtilen satiri siler."
                    sed "${SATIR}d" "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "silindi")
                    ;;
                4)
                    ogret_gui "awk '{print NR, \$0}'" "Her satirin basina numara ekler."
                    awk '{print NR, $0}' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "numarali")
                    ;;
                5)
                    KOLON=$(yad --entry --title="Sutun Ayikla" --text="Ayiklanacak Sutun No:" --center)
                    [[ -z "$KOLON" ]] && { rm -f "$STEP_FILE"; continue; }
                    ogret_gui "awk '{print \$$KOLON}'" "Sadece secilen sutunu ayiklar."
                    awk -v k="$KOLON" '{if ($k != "") print $k}' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "sutun$KOLON")
                    ;;
                6)
                    VERI=$(yad --form --title="Filtreleme" --field="Sutun No" --field="Alt Limit (Sayi)" --center)
                    [[ -z "$VERI" ]] && { rm -f "$STEP_FILE"; continue; }
                    K=$(echo $VERI | cut -d'|' -f1); L=$(echo $VERI | cut -d'|' -f2)
                    ogret_gui "awk '\$$K > $L'" "Sayısal karsilastirma yapar."
                    awk -v k="$K" -v l="$L" '$k > l' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "filtre")
                    ;;
                7)
                    K=$(yad --entry --title="Toplam Hesapla" --text="Toplanacak Sutun No:" --center)
                    [[ -z "$K" ]] && { rm -f "$STEP_FILE"; continue; }
                    ogret_gui "awk '{s+=\$k} END {print s}'" "Sutundaki tum sayisal degerleri toplar."
                    SONUC=$(awk -v k="$K" '{s+=$k} END {print s}' "$GECICI_DOSYA")
                    yad --info --text="Sutun $K Toplami: $SONUC" --center
                    rm -f "$STEP_FILE"; continue
                    ;;
                8)
                    yad --text-info --filename="$GECICI_DOSYA" --title="Dosya Onizleme" --width=600 --height=400 --center
                    rm -f "$STEP_FILE"; continue
                    ;;
            esac

            mv "$STEP_FILE" "$GECICI_DOSYA"
            if ! (yad --title="Onay" --text="Islem basarili. Devam edilsin mi?\n(Hayir derseniz dosya kaydedilir)" --button="Evet:0" --button="Hayir:1" --center); then
                KAYIT_ISMI=$(yad --entry --title="Dosyayi Kaydet" --text="Kaydedilecek dosya ismini girin:" --entry-text="$YENI_ISIM" --center --width=400)
                if [[ -n "$KAYIT_ISMI" ]]; then
                    yedekle_ve_kaydet "$GECICI_DOSYA" "$KAYIT_ISMI"
                    yad --info --text="Dosya Kaydedildi ve Yedek Alindi (varsa): $KAYIT_ISMI" --center
                fi
                rm -f "$GECICI_DOSYA"; break
            fi
        done
    done
}

# TUI 
calistir_tui() {
    while true; do
        ORJINAL_DOSYA=$(whiptail --title "Dosya Secimi" --inputbox "Duzenlenecek dosyanin yolunu girin:" 10 60 3>&1 1>&2 2>&3)
        [[ $? -ne 0 || -z "$ORJINAL_DOSYA" ]] && break
        
        if [[ ! -f "$ORJINAL_DOSYA" ]]; then
            whiptail --title "Hata" --msgbox "Dosya bulunamadi: $ORJINAL_DOSYA" 10 60
            continue
        fi

        GECICI_DOSYA=$(mktemp)
        cp "$ORJINAL_DOSYA" "$GECICI_DOSYA"
        YENI_ISIM="$ORJINAL_DOSYA"

        while true; do
            SEC=$(whiptail --title "Pardus Editor (TUI)" --menu "Dosya: $ORJINAL_DOSYA\nOlusacak Isim: $YENI_ISIM" 20 75 10 \
                "1" "Metin Icinde Kelime Degistir" \
                "2" "Bos Satirlari Temizle" \
                "3" "Belirli Bir Satiri Sil" \
                "4" "Satir Numarasi Ekle" \
                "5" "Belirli Bir Sutunu Ayikla" \
                "6" "Sarta Gore Filtrele (Deger > X)" \
                "7" "Sutun Toplami Hesapla" \
                "8" "Dosya Icerigi Goruntule" \
                "9" "Kaydet ve Baska Dosya Sec" \
                "10" "Geri Don" 3>&1 1>&2 2>&3)

            [[ $? -ne 0 || "$SEC" == "10" ]] && { rm -f "$GECICI_DOSYA"; break 2; }
            
            if [[ "$SEC" == "9" ]]; then
                KAYIT_ISMI=$(whiptail --title "Dosyayi Kaydet" --inputbox "Dosya ismini girin (Varsa .bak olusturulur):" 10 60 "$YENI_ISIM" 3>&1 1>&2 2>&3)
                if [[ -n "$KAYIT_ISMI" ]]; then
                    yedekle_ve_kaydet "$GECICI_DOSYA" "$KAYIT_ISMI"
                    whiptail --msgbox "Kaydedildi ve Yedeklendi: $KAYIT_ISMI" 10 60
                fi
                rm -f "$GECICI_DOSYA"; break
            fi

            STEP_FILE=$(mktemp)
            case $SEC in
                1)
                    ESKI=$(whiptail --inputbox "Eski Kelime:" 10 60 3>&1 1>&2 2>&3)
                    YENI=$(whiptail --inputbox "Yeni Kelime:" 10 60 3>&1 1>&2 2>&3)
                    [[ -z "$ESKI" ]] && { rm -f "$STEP_FILE"; continue; }
                    ESKI_ESC=$(guvenli_sed "$ESKI"); YENI_ESC=$(guvenli_sed "$YENI")
                    ogret_tui "sed 's/$ESKI_ESC/$YENI_ESC/g'" "Karakter korumali güvenli degisim."
                    sed "s/$ESKI_ESC/$YENI_ESC/g" "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "guncel")
                    ;;
                2)
                    sed '/^[[:space:]]*$/d' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "temiz")
                    ;;
                3)
                    SATIR_NO=$(whiptail --inputbox "Silinecek Satir No:" 10 60 3>&1 1>&2 2>&3)
                    [[ -z "$SATIR_NO" ]] && { rm -f "$STEP_FILE"; continue; }
                    sed "${SATIR_NO}d" "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "silindi")
                    ;;
                4)
                    awk '{print NR, $0}' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "numarali")
                    ;;
                5)
                    KOLON_NO=$(whiptail --inputbox "Sutun No:" 10 60 3>&1 1>&2 2>&3)
                    [[ -z "$KOLON_NO" ]] && { rm -f "$STEP_FILE"; continue; }
                    awk -v k="$KOLON_NO" '{print $k}' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "sutun$KOLON_NO")
                    ;;
                6)
                    K=$(whiptail --inputbox "Sutun No:" 10 60 3>&1 1>&2 2>&3)
                    L=$(whiptail --inputbox "Limit:" 10 60 3>&1 1>&2 2>&3)
                    awk -v k="$K" -v l="$L" '$k > l' "$GECICI_DOSYA" > "$STEP_FILE"
                    YENI_ISIM=$(isim_guncelle "$YENI_ISIM" "filtre")
                    ;;
                7)
                    K=$(whiptail --inputbox "Sutun No:" 10 60 3>&1 1>&2 2>&3)
                    SONUC=$(awk -v k="$K" '{s+=$k} END {print s}' "$GECICI_DOSYA")
                    whiptail --msgbox "Toplam: $SONUC" 10 60
                    rm -f "$STEP_FILE"; continue
                    ;;
                8) whiptail --textbox "$GECICI_DOSYA" 20 75; rm -f "$STEP_FILE"; continue ;;
            esac

            mv "$STEP_FILE" "$GECICI_DOSYA"
            if ! (whiptail --title "Onay" --yesno "Islem basarili. Devam edilsin mi?\n(Hayir derseniz dosya kaydedilir)" 12 60); then
                KAYIT_ISMI=$(whiptail --title "Dosyayi Kaydet" --inputbox "Kayit ismini onaylayin:" 10 60 "$YENI_ISIM" 3>&1 1>&2 2>&3)
                if [[ -n "$KAYIT_ISMI" ]]; then
                    yedekle_ve_kaydet "$GECICI_DOSYA" "$KAYIT_ISMI"
                    whiptail --msgbox "Dosya Kaydedildi ve Yedeklendi: $KAYIT_ISMI" 10 60
                fi
                rm -f "$GECICI_DOSYA"; break
            fi
        done
    done
}
