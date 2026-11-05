
import StoreKit
import Capacitor

@objc(IAPManager)
public class IAPManager: CAPPlugin {
    private var products: [Product] = []
    
    // ID продуктів - мають співпадати з App Store Connect
    let productIDs = [
        "com.blackjack21.chips500",
        "com.blackjack21.chips2500",
        "com.blackjack21.chips10000",
        "com.blackjack21.chips50000",
        "com.blackjack21.chips200000",
        "com.blackjack21.vip.weekly",
        "com.blackjack21.vip.monthly",
        "com.blackjack21.vip.yearly",
        "com.blackjack21.vip.lifetime"
    ]
    
    @objc func initialize(_ call: CAPPluginCall) {
        Task {
            await loadProducts()
            call.resolve(["status": "initialized", "products": products.map { $0.id }])
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            print("Завантажено продуктів: \(products.count)")
        } catch {
            print("Помилка завантаження продуктів: \(error)")
        }
    }
    
    @objc func purchase(_ call: CAPPluginCall) {
        guard let productID = call.getString("productId") else {
            call.reject("Немає productId")
            return
        }
        
        Task {
            guard let product = products.first(where: { $0.id == productID }) else {
                call.reject("Продукт не знайдено")
                return
            }
            
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        // Успішна покупка
                        await transaction.finish()
                        
                        // Відправляємо подію в веб-гру
                        let chips = getChipsForProduct(productID)
                        let isVIP = productID.contains("vip")
                        
                        self.notifyListeners("purchaseSuccess", data: [
                            "productId": productID,
                            "chips": chips,
                            "isVIP": isVIP
                        ])
                        
                        call.resolve([
                            "success": true,
                            "productId": productID,
                            "chips": chips
                        ])
                    case .unverified:
                        call.reject("Транзакція не верифікована")
                    }
                case .userCancelled:
                    call.reject("Користувач скасував")
                case .pending:
                    call.resolve(["success": false, "status": "pending"])
                @unknown default:
                    call.reject("Невідомий статус")
                }
            } catch {
                call.reject("Помилка покупки: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func restorePurchases(_ call: CAPPluginCall) {
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // Відновлюємо VIP якщо є
                    if transaction.productID.contains("vip") {
                        self.notifyListeners("vipRestored", data: ["productId": transaction.productID])
                    }
                }
            }
            call.resolve(["restored": true])
        }
    }
    
    func getChipsForProduct(_ id: String) -> Int {
        switch id {
        case "com.blackjack21.chips500": return 500
        case "com.blackjack21.chips2500": return 2500
        case "com.blackjack21.chips10000": return 10000
        case "com.blackjack21.chips50000": return 50000
        case "com.blackjack21.chips200000": return 200000
        default: return 0
        }
    }
    
    // Слухаємо оновлення транзакцій
    public override func load() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }
}
