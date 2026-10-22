# ZihinLab (Flutter MVP)

Türkçe mantık ve kelime bulmacaları; koyu lacivert, neon mavi/mor arayüz, üç aşamalı ipucu, cevap açıklaması, yıldız/puan ve SharedPreferences ile cihazda ilerleme kaydı.

## Gereksinimler
Flutter stable (Dart SDK dahildir) ve Android Studio/Android SDK.

## Yerelde çalıştırma
```bash
flutter create . --platforms=android --org com.zihinlab
flutter pub get
flutter run
```
Bu kaynak paketi Android platform klasörünü içermez; ilk çalıştırma komutu güncel Android dosyalarını üretir.

## Kontrol
```bash
flutter analyze
flutter test
```

## Github Actions ile APK/AAB
1. Bu klasörü GitHub'da yeni depoya gönderin; varsayılan dal `main` veya `master` olsun.
2. `.github/workflows/android.yml` push, pull request veya elle başlatıldığında analiz ve testleri çalıştırır, release APK ve AAB üretir.
3. GitHub deposunda Actions sekmesinden başarılı çalışmayı açıp `zihinlab-android` artifact'ini indirin. APK cihaza kurulabilir; AAB Play Console'a yüklenebilir.
4. Elle çalıştırmak için Actions → Android APK and AAB → Run workflow.

Play Store için workflow çıktısı imzasızdır. Yayın öncesi Android release keystore ve GitHub Secrets ile imzalama yapılandırılmalıdır; özel anahtarları depoya koymayın.

Üç starter seviye içerir. İlk doğru çözümde kullanılan ipucu sayısına göre 1–3 yıldız ve orantılı puan kazanılır; tekrar çözüm ek puan vermez. Yeni bulmacalar için `lib/data/puzzle_bank.dart` içindeki Puzzle listesine benzersiz ID, cevaplar, üç ipucu ve açıklama ekleyin.
