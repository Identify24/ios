# Identify SDK

Proje ile ilgili dökümantasyona https://docs.identify.com.tr/docs/ios/first-setup/ adresinden ulaşabilirsiniz.

## 1.9.2 // Buradaki özellikler için mutlaka SDK 1.9.2 sürümüne geçmelisiniz!
- nfc okunamaması durumunda panelden nfc key - value girilebilen ekranının tetiklenme özelliği eklendi (SDKNFCViewController ve SDKCallScreenViewController'da işlemler yapıldı)
- nfc reader için sdkPassportList.pem dosyası eklendi (projenize eklemelisiniz, aksi takdirde nfc okuyucu hata verecektir!)
- subscribe methodune project_id eklendi

## 1.9.1
- canlılık testi ile ilgili güncellemeler yapıldı
- socket disconnect&connect durumunda bekleme odasına düşmesi sağlandı

## 1.9 // Örnek uygulamanın çalışması için bu sürüme geçmelisiniz!
- webrtc bölümünde gelen görüntülerde aspect ayarı düzenlendi
