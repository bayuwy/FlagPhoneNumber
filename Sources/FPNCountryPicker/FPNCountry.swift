import UIKit

public struct FPNCountry {
	public var code: FPNCountryCode
	public var name: String
	public var phoneCode: String
	var flag: UIImage?

	public init(code: String, name: String, phoneCode: String) {
		self.name = name
		self.phoneCode = phoneCode
		self.code = FPNCountryCode(rawValue: code)!

		if let flag = UIImage(named: code, in: Bundle.FlagIcons, compatibleWith: nil) {
			self.flag = flag
		} else {
			self.flag = UIImage(named: "unknown", in: Bundle.FlagIcons, compatibleWith: nil)
		}
	}
}

public extension FPNCountry {
    
    static func getAllCountries(locale: Locale? = nil) -> [FPNCountry] {
        let bundle: Bundle = Bundle.FlagPhoneNumber()
        let resource: String = "countryCodes"
        let jsonPath = bundle.path(forResource: resource, ofType: "json")
        
        assert(jsonPath != nil, "Resource file is not found in the Bundle")
        
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath!))
        
        assert(jsonPath != nil, "Resource file is not found")
        
        var countries = [FPNCountry]()
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    guard let countryObj = jsonObject as? NSDictionary else { return countries }
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else { return countries }
                    
                    if let locale = locale {
                        let country = FPNCountry(code: code, name: locale.localizedString(forRegionCode: code) ?? name, phoneCode: phoneCode)
                        
                        countries.append(country)
                    } else {
                        let country = FPNCountry(code: code, name: name, phoneCode: phoneCode)
                        
                        countries.append(country)
                    }
                }
                
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        return countries.sorted(by: { $0.name < $1.name })
    }
    
    static func getAllCountries(excluding countryCodes: [FPNCountryCode]) -> [FPNCountry] {
        var allCountries = getAllCountries()
        
        for countryCode in countryCodes {
            allCountries.removeAll(where: { (country: FPNCountry) -> Bool in
                return country.code == countryCode
            })
        }
        return allCountries
    }
    
    static func getAllCountries(equalTo countryCodes: [FPNCountryCode]) -> [FPNCountry] {
        let allCountries = getAllCountries()
        var countries = [FPNCountry]()
        
        for countryCode in countryCodes {
            for country in allCountries {
                if country.code == countryCode {
                    countries.append(country)
                }
            }
        }
        return countries
    }
}
