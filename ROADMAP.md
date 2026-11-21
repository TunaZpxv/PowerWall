# 🗺️ PowerWall 2.0 Roadmap

> 🚀 Hedef: Daha akıllı, daha hafif, daha kullanıcı dostu bir canlı duvar kağıdı deneyimi.

## 📊 Tahmini Sayısal Hedefler

| Metrik | v1.0 | v2.0 (hedef) |
|---|---|---|
| Uygulama boyutu | ~1.2 MB | < 1 MB |
| CPU (animasyon açık, yük altında) | %18-25 | %8-12 |
| Enerji (pil, 1 saat) | ~4.5 Wh | ~2.1 Wh |
| Bildirim gecikmesi | - | < 1 sn |
| Kütüphane öğe sayısı | 0 | 20+ |

## 🧠 Bölüm 1: İşlemci yüküne duyarlı koruma ⚡

- 🔋 Termal durum + Düşük Güç Modu birincil sinyal
- 📈 Toplam CPU ek sinyal olarak kalır
- 🔁 Geçişler kararlı (hysteresis + kısa ortalamalar)
- 🔔 Yük başına tek bildirim, sessize alınabilir
- 🎛️ Aç/kapa + hassasiyet seçimi + menüde duraklatma nedeni
- 🎬 Fade efekti ile tutarlı geçiş
- 📉 Kanıt: açık/kapalı CPU & enerji ölçümü README'ye eklenecek

```mermaid
pie title Sinyal Ağırlıkları (v2.0)
    "Termal durum" : 45
    "Düşük Güç Modu" : 30
    "Toplam CPU" : 25
```

## 📚 Bölüm 2: Hazır kütüphane 🎨

- 🪶 1 MB altı uygulama korunur (içerik indirilmeli)
- 🗂️ Ayrı içerik listesi (ad, kategori, önizleme, boyut, lisans, yapımcı)
- ⚖️ Sadece yeniden dağıtımına izin verilen içerikler
- 🎞️ Kısa, kesintisiz, düşük bitrate videolar
- 🔒 Ağ erişimi yalnızca kütüphane için, veri toplanmaz
- ✅ İndirme doğrulama, hata yönetimi, iptal
- 📁 Bilinen klasör + kullanıcı silme yetkisi
- 🖥️ "Kütüphane" sekmesi, kategoriler, önizleme, ilerleme
- 🔌 Şarj/pil ataması + pil modunda hareketli içerikte "sadece bildir" kuralı

```mermaid
bar
    title Kütüphane Hedefleri
    x-axis Kategori
    y-axis Öğe Sayısı
    "Doğa" : 6
    "Soyut" : 5
    "Şehir" : 4
    "Minimal" : 5
```

## ☕ Destek & İletişim

- ▶️ [YouTube Kanalı](https://www.youtube.com/@Tuna-zpxv)
- 💛 [Buy Me a Coffee](https://www.buymeacoffee.com/)
- 📧 Contact: tuna@example.com
