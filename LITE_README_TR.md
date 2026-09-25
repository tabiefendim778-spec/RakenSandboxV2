# RAKEN SANDBOX — Lite Edition

Bu klasör, Unreal Engine kurmak için yeterli disk alanı olmayan sistemler için hazırlanan alternatif sürümdür.

Motor: **Godot 4.7.2 stable**  
Renderer: **GL Compatibility**  
Hedef: düşük depolama kullanımıyla kaliteli ana menü, prosedürel uzay görselleri ve gerçek zamanlı N-body sandbox çekirdeği.

## En kolay çalıştırma

Repo ana klasöründeki:

`RUN_LITE.bat`

dosyasını çalıştır.

İlk çalıştırmada portable Godot motoru `.raken_tools` altına otomatik indirilir. Windows'a büyük bir motor kurulumu yapılmaz.

## EXE üretme

`BUILD_LITE.bat`

dosyasını çalıştır. İlk export sırasında Godot export template paketi de gerekir. Çıktı:

`BuildLite\RAKEN_SANDBOX.exe`

## Şu anki özellikler

- Animasyonlu prosedürel uzay ana menüsü
- Splash / giriş ekranı ve geçiş animasyonları
- Ayarlar paneli, fullscreen, V-Sync ve kalite profili
- GL Compatibility renderer
- Güneş, Dünya, Ay, Mars, Jüpiter ve Satürn başlangıç sistemi
- N-body yerçekimi
- Çarpışma ve kütle/momentum korunumu ile birleşme
- Prosedürel gezegen shader'ı
- Atmosfer katmanı
- Emissive yıldız shader'ı ve yıldız ışığı
- Karadelik + akresyon diski
- Satürn halka görseli
- 3D yıldız alanı
- Serbest uzay kamerası
- Obje seçme/inspector
- Pause menüsü
- Zaman hızlandırma/yavaşlatma
- Runtime gezegen/yıldız/karadelik oluşturma
- F5/F9 quick save/load

## Kontroller

- WASD: hareket
- Q / E: aşağı / yukarı
- Mouse: kamera
- Shift: boost
- Sol tık: gök cismi seç
- Space: simülasyonu durdur/devam ettir
- [ / ]: zamanı yavaşlat/hızlandır
- 1: gezegen oluştur
- 2: yıldız oluştur
- 3: karadelik oluştur
- F5: hızlı kaydet
- F9: hızlı yükle
- Esc: pause menüsü

Bu sürüm Unreal V2'yi silmez; repoda iki hat birlikte tutulur.
