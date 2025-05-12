import HomeKit

class HomeKitManager: NSObject, ObservableObject {
    @Published var accessories: [HMAccessory] = []
    @Published var isAuthorized = false
    @Published var error: String?
    
    private var home: HMHome?
    private let homeManager = HMHomeManager()
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func requestAccess() {
        homeManager.delegate = self
    }
    
    func togglePlug(_ accessory: HMAccessory) {
        guard let characteristic = accessory.find(serviceType: HMServiceTypePowerOutlet,
                                                characteristicType: HMCharacteristicTypeOn) else {
            self.error = "Could not find power characteristic"
            return
        }
        
        let newValue = !(characteristic.value as? Bool ?? false)
        characteristic.writeValue(newValue) { error in
            if let error = error {
                self.error = error.localizedDescription
            }
        }
    }
}

extension HomeKitManager: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if let primaryHome = manager.primaryHome {
            self.home = primaryHome
            self.accessories = primaryHome.accessories.filter { accessory in
                accessory.services.contains { service in
                    service.serviceType == HMServiceTypePowerOutlet
                }
            }
            self.isAuthorized = true
        }
    }
}

extension HMAccessory {
    func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
        return services.first { service in
            service.serviceType == serviceType
        }?.characteristics.first { characteristic in
            characteristic.characteristicType == characteristicType
        }
    }
}
