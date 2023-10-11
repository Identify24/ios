# Identify SDK

Proje ile ilgili dökümantasyona https://docs.identify.com.tr/docs/ios/first-setup/ adresinden ulaşabilirsiniz.

## 1.9.4
- network timeout süreleri eklendi
- webrtc kamera setup, sadece görüşme modülüne geçince aktif hale getirildi
- 14 pro ve üstü cihazlar için kamera ayarları düzenlendi, bu cihazlarda oluşan netleme sorunu düzeltildi
- default kamera çözünürlükleri güncellendi

## 1.9.3
- SDK setup ekranında URLLER için gerekli olan "/" zorunluluğu kaldırıldı
- WebSocket bağlantısı kopması durumunda detaylı hata mesajı eklendi
- Selfie aşamasında birden fazla surat varsa hata verilmesi sağlandı
- NFC mesajlarını kişiselleştirme eklendi (https://docs.identify.com.tr/docs/ios/modul-listesi/nfc/#nfc-mesajlarını-kişiselleştirmek-1-9-3-ve-üstü-sürümlerde-çalışı)

## 1.9.2 // Buradaki özellikler için mutlaka SDK 1.9.2 sürümüne geçmelisiniz!
- nfc okunamaması durumunda panelden nfc key - value girilebilen ekranının tetiklenme özelliği eklendi (SDKNFCViewController ve SDKCallScreenViewController'da işlemler yapıldı)
- nfc reader için sdkPassportList.pem dosyası eklendi (projenize eklemelisiniz, aksi takdirde nfc okuyucu hata verecektir!)
- subscribe methodune project_id eklendi
