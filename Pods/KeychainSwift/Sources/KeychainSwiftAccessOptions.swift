import Security

/**

These options are used to determine when a keychain item should be readable. The default value is AccessibleWhenUnlocked.

*/
public enum KeychainSwiftAccessOptions {
  
  /**
  
  The data in the keychain item can be accessed only while the device is unlocked by the user.
  
  This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
  
  This is the default value for keychain items added without explicitly setting an accessibility constant.
  
  */
  case accessibleWhenUnlocked
  
  /**
  
  The data in the keychain item can be accessed only while the device is unlocked by the user.
  

  */
  case accessibleWhenUnlockedThisDeviceOnly
  
  /**
  
  The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  

  
  */
  case accessibleAfterFirstUnlock
  
  /**
  
  The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  

  
  */
  case accessibleAfterFirstUnlockThisDeviceOnly

  /**
  
  The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.

  
  */
  case accessibleWhenPasscodeSetThisDeviceOnly
  
  static var defaultOption: KeychainSwiftAccessOptions {
    return .accessibleWhenUnlocked
  }
  
  var value: String {
    switch self {
    case .accessibleWhenUnlocked:
      return toString(kSecAttrAccessibleWhenUnlocked)
      
    case .accessibleWhenUnlockedThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
      
    case .accessibleAfterFirstUnlock:
      return toString(kSecAttrAccessibleAfterFirstUnlock)
      
    case .accessibleAfterFirstUnlockThisDeviceOnly:
      return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
      
    case .accessibleWhenPasscodeSetThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    }
  }
  
  func toString(_ value: CFString) -> String {
    return KeychainSwiftConstants.toString(value)
  }
}
