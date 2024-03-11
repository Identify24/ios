# Identify SDK Sample App
Proje ile ilgili dökümantasyona ve SDK download linkine https://docs.identify.com.tr/docs/ios/first-setup/ adresinden ulaşabilirsiniz.

### Sample App 

## Build 84:
- scanner ekranında kimliğin yatay olma zorunluluğu iptal edildi
- login ekranı yeni SDK kurulumuna göre düzenlendi
- login ekranında socket hata vermesi durumunda ekstra durum bildirimi eklendi



## Build 80:
- scanner ekranında daha hızlı fotoğraf çekimi sağlandı 
- active result için NfcViewController, CardreaderViewController ve ThankYouViewController buna bağlı olarak güncellendi
- scanner için yatay fotoğraf çekilmesi zorunluluğu eklendi
- dil dosyaları güncellendi

## Build 75:
- Scanner ve onu çağıran ekranlar güncellendi
- Prepare modülü için örnek ekran eklendi
- Missed Call için yeni status eklendi
- Teşekkür ekranı güncellendi


## Build 73:
- prepare modülünün örnek tasarımı eklendi
- socketListener tarafına connectionErr eklendi
- button tiplerine loader eklendi
- socket bağlantısı kopması durumunda çıkan ekran güncellendi



### SDK Son Güncelleme:

## 2.0.1
- active result desteği eklendi
- ocr alanında güncellemeler yapıldı

## 1.9.8
- bağlantı hızına bağlı olarak kamera güncellemesi düzenlendi
- prepare modülünün panele attığı istek eklendi

## 1.9.7
- prepare modülü eklendi
- forceQuitSDK eklendi
- socket disconnect olunca socket listener için method eklendi (.connectionErr)
- ocr tarafında güncelleme yapıldı
