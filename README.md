# 🪄 Sed Awk Editor
### Sed & Awk Tabanlı Metin Düzenleyici

Sed awk editor Linux sistemlerde (Pardus, Ubuntu, Debian vb.) metin dosyaları üzerinde **sed** ve **awk** komutlarını kullanıcı dostu bir arayüzle kullanmayı sağlayan bir **Shell Programming projesidir**.  
Uygulama hem **Grafik Arayüz (GUI)** hem de **Terminal Arayüzü (TUI)** sunarak farklı kullanım senaryolarına uyum sağlar.

---

## 📝 Proje Tanıtımı

Bu proje, metin dosyaları üzerinde sık kullanılan işlemleri (kelime değiştirme, boş satır temizleme, sütun bazlı işlemler, sayısal hesaplamalar vb.) **menü tabanlı** bir yapı ile gerçekleştirmeyi amaçlar.

Linux Text Alchemy’nin ayırt edici özelliği, yapılan her işlemin arka planda çalışan **sed** ve **awk** komutlarını kullanıcıya göstermesidir. Bu sayede uygulama yalnızca bir araç değil, aynı zamanda **öğretici bir eğitim uygulaması** olarak da kullanılabilir.

---

## 🚀 Özellikler

- **Çift Arayüz Desteği**
  - Grafik Arayüz: `yad`
  - Terminal Arayüzü: `whiptail`

- **Güvenli Dosya İşleme**
  - Orijinal dosya korunur
  - İşlemler geçici dosyalar üzerinde yapılır

- **Otomatik Yedekleme**
  - Kaydetme sırasında mevcut dosyanın `.bak` uzantılı yedeği alınır

- **Özel Karakter Koruması**
  - `/`, `&`, `.` gibi özel karakterler otomatik olarak escape edilir
  - Hatalı sed işlemleri engellenir

- **Eğitici Mod**
  - Çalıştırılan `sed` ve `awk` komutları açıklamalarıyla birlikte gösterilir

---

## 🛠 Kurulum ve Sistem Gereksinimleri

### Desteklenen Sistemler
- Pardus
- Ubuntu
- Debian

### Gerekli Paketler
- `bash`
- `sed`
- `awk`
- `yad`
- `whiptail`

### Bağımlılıkların Kurulması

```bash
sudo apt update
sudo apt install yad whiptail -y

## ▶️ Uygulamanın Çalıştırılması

1. Depoyu klonlayın:
```bash
git clone https://github.com/kullanici-adi/sedawk-araci.git
Proje dizinine girin:

bash
Kodu kopyala
cd sedawk-araci
Çalıştırma izinlerini verin:

bash
Kodu kopyala
chmod +x *.sh
Ana programı başlatın:

bash
Kodu kopyala
./ana_program.sh
📖 Kullanım Kılavuzu
1️⃣ Arayüz Seçimi
Program başladığında kullanıcıdan aşağıdaki arayüzlerden birini seçmesi istenir:

Grafik Arayüz (YAD)

Terminal Arayüzü (Whiptail)

📸 Ekran Görüntüsü:


2️⃣ Dosya Seçimi ve İşlemler
İşlem yapılacak metin dosyası seçilir

Aşağıdaki işlemlerden biri uygulanabilir:

Kelime değiştirme

Boş satırları temizleme

Belirli sütunları ayıklama

Sayısal sütun toplamı alma

📸 Ekran Görüntüsü:


3️⃣ Kaydetme ve Yedekleme
Dosya kaydedilirken:

Aynı isimde bir dosya varsa otomatik olarak .bak uzantılı yedeği oluşturulur

📸 Ekran Görüntüsü:


🏗 Proje Yapısı
text
Kodu kopyala
sedawk-araci/
│
├── ana_program.sh
├── arayuzler.sh
├── fonksiyonlar.sh
├── README.md
└── screenshots/
