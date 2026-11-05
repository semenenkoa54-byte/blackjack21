
// iOS IAP Bridge - додай цей код в свою веб-гру
// Викликається коли гра працює в Capacitor

import { Capacitor } from '@capacitor/core';

export async function initIAP() {
  if (!Capacitor.isNativePlatform()) {
    console.log("Веб-версія - демо покупки");
    return { isNative: false };
  }
  
  const { IAPManager } = Capacitor.Plugins;
  await IAPManager.initialize();
  return { isNative: true };
}

export async function buyProduct(productId) {
  if (!Capacitor.isNativePlatform()) {
    // Демо в браузері
    return { success: true, demo: true };
  }
  
  const { IAPManager } = Capacitor.Plugins;
  try {
    const result = await IAPManager.purchase({ productId });
    return result;
  } catch (e) {
    console.error("Помилка покупки", e);
    return { success: false, error: e.message };
  }
}

// Слухаємо події від нативного коду
export function listenForPurchases(callback) {
  if (!Capacitor.isNativePlatform()) return;
  
  const { IAPManager } = Capacitor.Plugins;
  IAPManager.addListener('purchaseSuccess', (data) => {
    console.log("Купівля успішна", data);
    callback(data);
    // Тут додай фішки: addChips(data.chips)
    // Якщо VIP: activateVIP()
  });
}
