import UIKit

open class FPNCountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

	var countries: [FPNCountry]! {
		didSet {
			reloadAllComponents()
		}
	}

	open var selectedLocale: Locale?
	weak var countryPickerDelegate: FPNCountryPickerDelegate?
	open var showPhoneNumbers: Bool = true

	override init(frame: CGRect) {
		super.init(frame: frame)

		setup()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setup()
	}

	func setup() {
		if let code = Locale.preferredLanguages.first {
			self.selectedLocale = Locale(identifier: code)
		}

		countries = FPNCountry.getAllCountries(locale: selectedLocale)

		super.dataSource = self
		super.delegate = self
	}

	public func setup(with countryCodes: [FPNCountryCode]) {
		countries = FPNCountry.getAllCountries(equalTo: countryCodes)

		if let code = countries.first?.code {
			setCountry(code)
		}
	}

	public func setup(without countryCodes: [FPNCountryCode]) {
		countries = FPNCountry.getAllCountries(excluding: countryCodes)

		if let code = countries.first?.code {
			setCountry(code)
		}
	}

	// MARK: - Locale Methods

	open func setLocale(_ locale: String) {
		self.selectedLocale = Locale(identifier: locale)
	}

	// MARK: - FPNCountry Methods

	open func setCountry(_ code: FPNCountryCode) {
		for index in 0..<countries.count {
			if countries[index].code == code {
				return self.setCountryByRow(row: index)
			}
		}
	}

	func setCountryByRow(row: Int) {
		self.selectRow(row, inComponent: 0, animated: true)

		if countries.count > 0 {
			let country = countries[row]

			countryPickerDelegate?.countryPhoneCodePicker(self, didSelectCountry: country)
		}
	}

	// MARK: - Picker Methods

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return countries.count
	}

	open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var resultView: FPNCountryView

		if view == nil {
			resultView = FPNCountryView()
		} else {
			resultView = view as! FPNCountryView
		}

		resultView.setup(countries[row])

		if !showPhoneNumbers {
			resultView.countryCodeLabel.isHidden = true
		}
		return resultView
	}

	open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if countries.count > 0 {
			let country = countries[row]

			countryPickerDelegate?.countryPhoneCodePicker(self, didSelectCountry: country)
		}
	}
}
