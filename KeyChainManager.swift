import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    
    private let serviceIdentifier = "com.yourdomain.iptvapp"
    
    private init() {}
    
    func savePassword(_ password: String, for username: String) {
        let passwordData = Data(password.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: username
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            let attributesToUpdate: [String: Any] = [kSecValueData as String: passwordData]
            SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        } else if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = passwordData
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
    
    func getPassword(for username: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func deletePassword(for username: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: username
        ]
        SecItemDelete(query as CFDictionary)
    }
}