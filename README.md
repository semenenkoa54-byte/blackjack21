# Blackjack 21 - iOS Project for App Store

Цей проект - готова обгортка для твоєї веб-гри.

## Що всередині:
- Веб-гра з папки dist (скопіюй туди файл з артефакту)
- StoreKit 2 інтеграція для покупок
- In-App Purchase продукти налаштовані

## Кроки для публікації в App Store:

### 1. Підготовка
- Встанови Node.js, Xcode
- npm install
- npm run build (скопіюй dist з грою)
- npx cap add ios
- npx cap sync ios
- npx cap open ios

### 2. StoreKit - налаштуй в Xcode:
Відкрий ios/App/App/IAPManager.swift - там весь код покупок.
Додай продукти в App Store Connect:
- com.blackjack21.chips500 - $0.99
- com.blackjack21.chips2500 - $4.99
- com.blackjack21.chips10000 - $9.99
- com.blackjack21.chips50000 - $19.99
- com.blackjack21.vip.weekly - $2.99 (підписка)
- com.blackjack21.vip.monthly - $7.99
- com.blackjack21.vip.yearly - $39.99
- com.blackjack21.vip.lifetime - $79.99 (одноразова)

### 3. Важливо для Apple (Social Casino):
В App Store Connect вкажи:
- Категорія: Games -> Casino
- Вікове обмеження: 17+ (Gambling)
- В описі: "This is a social casino game. No real money gambling. Chips have no cash value and cannot be cashed out."
- Додай ліцензію що це розважальна гра

### 4. Збірка і заливка:
- В Xcode: Product -> Archive
- Distribute App -> App Store Connect
- Заповни скріншоти, іконку, опис
- Submit for Review

Готово!
