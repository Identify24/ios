# Identify SDK

Proje ile ilgili dökümantasyona https://docs.identify.com.tr/docs/ios/first-setup/ adresinden ulaşabilirsiniz.


## version:1 build:5
- bazı kimliklerde gerçekleşen, MRZ alanından yanlış yorumlanan seri numarası hatası düzeltildi.
- sdk çalıştırılınca log bölümüne sürüm bilgisi eklendi

## version:1 build:4
- kimlik ve pasaport için MRZ alanının alınma fonksiyonu güncellendi
- bazı pasaportlarda ad & soyad verisi NFC'den alınırken boş geliyordu, güncellendi

## version:1 build:3
- ocr ile ilgili okuma bölümünde güncelleme yapıldı

## version:1 build:2
- missedCall eklendi (SDKCallScreenViewController.swift:211)
- SDK çalışırken araya farklı bir controller eklemek istemeniz durumunda yapmanız gerekenler eklendi, dökümantasyonda görüntüleyebilirsiniz (SDKSignatureViewController.swift dosyasında örnek kod mevcut) 
https://docs.identify.com.tr/docs/ios/first-setup/ilk-baglantiyi-kuralim/#external
