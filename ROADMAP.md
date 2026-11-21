# PowerWall 2.0 Roadmap

## Bölüm 1: İşlemci yüküne duyarlı koruma

İşlemci yükü artarsa ve pil modundaki içerik statikse (resim ya da macOS varsayılanı), animasyon kapanır, sistem pil modundaki içeriğe döner. Yük normale dönünce animasyon geri gelir.
İşlemci yükü artarsa ama kullanıcı pil modunda hareketli bir içerik (video ya da GIF) kullanıyorsa, sistem hiçbir şeyi değiştirmez. Sadece bir kez sesli bildirim verir: "İşlemciye yük bindi, duvar kağıdını kapatmanız önerilir."

Karar mantığı tek ve saf olmalı. Yük durumu, pil modu içeriğinin türü ve kullanıcı ayarı girdi olur, çıktı üç seçenekten biri olur: devam, statiğe geç, sadece bildir.
Termal durum ve Düşük Güç Modu birincil sinyal olmalı, toplam CPU ek sinyal olarak kalmalı.
Uygulama kendi yükünü ölçüme katmamalı.
Geçişler kararlı olmalı (kısa süreli ortalama, farklı eşikler).
Bildirim yük artışı başına bir kez çalmalı.
Özellik açılıp kapatılabilmeli, hassasiyet seçilebilmeli, menüde duraklatma nedeni görünmeli.
Mevcut fade efekti kullanılmalı.
Etkisi kanıtlanmalı (CPU/enerji ölçümü README'ye eklenecek).

## Bölüm 2: Hazır kütüphane

Kendi canlı duvar kağıdı olmayan kullanıcı, uygulama içindeki listeden bir seçenek seçip "Kur" der, içerik indirilir ve kullanılabilir hale gelir.

Duvar kağıtları uygulamaya gömülmemeli, ihtiyaç olunca indirilmeli ("1 MB altı uygulama" korunur).
İçerik listesi ayrı bir dosyada tutulmalı (ad, kategori, önizleme, boyut, lisans, yapımcı).
Sadece yeniden dağıtımına izin verilen içerikler, her öğede yapımcı ve lisans görünmeli.
Kısa, kesintisiz döngülü, düşük bitrate'li videolar.
Ağ erişimi yalnızca kütüphane kullanıldığında devreye girmeli, veri toplanmamalı, README'de açıkça yazılmalı.
İndirme güvenilir olmalı (hash/doğrulama, hata yönetimi, iptal).
İndirilenler bilinen klasörde durmalı, kullanıcı silebilmeli.
Ayarlarda "Kütüphane" sekmesi, kategoriler, önizleme, ilerleme göstergesi.
İndirilen içerik "şarjdayken" ya da "pilde" olarak kolayca atanabilmeli; pil modunda hareketli içerik seçilirse Bölüm 1 "sadece bildir" kuralı otomatik çalışmalı.
