//
//  MainViewController.swift
//  MyWeatherApp
//
//  Created by Sreenivas Babu on 8/20/23.
//

import UIKit
import SwiftUI

import CoreLocation
import CoreLocationUI

// Design decisions
// Check for local city, if valid get the weather and display.
// If local city is not valid, check for the most recent city and get weather
// else wait for input

//TODO: debug logging with tiers and remote enable/disable
//TODO: MVVM design,
//TODO: city names with spaces may not work and we can use lat long for this if reverse geo coding is successful for city name (may need to sue state country)


//TODO: enhancement: implement the switch of the units and save to the master data
var isMetric = false // switch this value to test
let centigradeUnit = "°C"
let fahrenheitUnit = "°F"

let keyCity = "Atlanta"

// simplifies the localization. can be moved to VM.
postfix operator ~
postfix func ~ (string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

class MainViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherInfoLabel: UILabel!
    @IBOutlet weak var weatherCityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionView: UIView!
    
    let locationManager = CLLocationManager() //can improve this location.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //location access
        setupLocationAuthorization()
        
        self.weatherCityNameLabel.text = ""
        self.weatherInfoLabel.text = ""
        
        guard let lastSavedCity = self.getLastSavedCity() else {return}
        weatherCityNameLabel.text = lastSavedCity
        fetchWeatherData(city: lastSavedCity)
    }
    
    //MARK: corelocation  setup
    // location access can have separate implemetation
    func setupLocationAuthorization() {
        
        //set up localized reason for NSLocationWhenInUseUsageDescription
        //handle the usecases when user declines : default to last searched location or myCity value
        //defaulting to mycity may cause some privacy concerns to the actual users in mycity (If we make this decision for actual consumer product)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // dont need high accuracy
        locationManager.startUpdatingLocation()
        
    }
    
    
    func fetchWeatherData(city: String) {
        
        //isMetric option , tie this isMetric to a toggle in the UI for user to set
        //can be changed and change will trigger new API call and UI refresh or local conversion.

        WeatherService.shared.getWeather(city: city, isMetric: isMetric) { weather, error in
            if let error = error {
                print(error)
                self.displayErrorMessage(error: error)
                return
            }
            if let weatherData = weather {
                let weatherIconURLString = weatherData.icon
                guard let weatherIconURL = URL(string: weatherIconURLString) else {
                    self.displayErrorMessage(error: .invalidUrl)
                    return
                }
                //Check if the icon exists in the ImageCache
                // user weatherIconURL as the Lookup key for cache, we can use just image name but
                //complete url may keept his unique if we are using images from other sources in cache.
                
                if let weatherIcon = ImageCache.shared.getImage(for: weatherIconURL) {
                    self.saveCityAndUpdateUI(city: city,
                                             iconImage: weatherIcon,
                                             temp: weatherData.temp,
                                             desc: weatherData.description)
                } else {
                    // Download the image and add to the ImageCache
                    WeatherService.shared.getImageData(from: weatherIconURL) { data, response, error in
                        if let error = error {
                            print("Error while getting the weather icon", error)
                            self.displayErrorMessage(error: .imageError)
                            return
                        }
                        guard let data = data,
                              let iconImage = UIImage(data: data) else {
                            print("Error while getting the weather icon data")
                            self.displayErrorMessage(error: .imageError)
                            return
                        }
                        ImageCache.shared.setImage(image: iconImage, for: weatherIconURL)
                        self.saveCityAndUpdateUI(city: city,
                                                 iconImage: iconImage,
                                                 temp: weatherData.temp,
                                                 desc: weatherData.description)
                    }
                }
            }
        }
    }
    func saveCityAndUpdateUI(city: String, iconImage: UIImage, temp: Double, desc: String){
        saveLastSearchedCity(city: city)

        let temperatureString = "temperature"~
        let unitsString = isMetric ? centigradeUnit : fahrenheitUnit
        
        DispatchQueue.main.async {
            self.weatherCityNameLabel.text = city
            self.weatherIconImageView.image = iconImage
            self.weatherInfoLabel.text = "\(temperatureString): \(temp) \(unitsString)"
            
            // Adding a swiftUI view to display description in the current view
            let swiftUIViewController = UIHostingController(rootView: WeatherSwiftUIView(description: desc))
            self.addChild(swiftUIViewController)
            swiftUIViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.weatherDescriptionView.addSubview(swiftUIViewController.view)
            swiftUIViewController.didMove(toParent: self)
        }
    }
    func displayErrorMessage(error: WeatherError){
        var errorMessage = k_error_message
         
        //TODO: Localize UI/Strings
        
        switch error {
        case .invalidUrl:
            errorMessage = "Invalid url error"
            break
        case .cityNotFound:
            errorMessage = "City not found"
            break
        case .jsonDataError:
            errorMessage = "Error while getting json data"
            break
        case .networkError:
            errorMessage = "Network error"
            break
        case .imageError:
            errorMessage = "Error getting the image"
            break
        }
        DispatchQueue.main.async {
            self.weatherIconImageView.image = nil
            self.weatherInfoLabel.text = errorMessage
            self.weatherCityNameLabel.text = ""
            self.weatherDescriptionView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    //MARK: location manager delegate classes
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get the current location and reverse geocode to get city name. If city name is valid,
        // default the weather to current city. You can fill up the text field with local city
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard error == nil else {
                    //implement localization for UI
                    _ = error?.localizedDescription ?? "Failed: reverseGeocodeLocation"
                    return
                }
                
                guard let localCity = placemarks?.first?.locality else {
                    //implement localization for UI.
                    print("Failed: City name is not valid")
                    return
                }
                //TODO: this can be done better with ViewModel
                // reactive: setting a value can trigger the UI updates.
                self.saveLastSearchedCity(city: localCity)
                self.weatherCityNameLabel.text = localCity
                self.fetchWeatherData(city: localCity)
                
            }
        }
        
        // You can use the latitude and longitude here as needed.
        
        // Stop updating location to save battery once you have the coordinates you need.
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //TODO: localize the UI with error message.
        print("Location manager error: \(error.localizedDescription)")
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text =  textField.text {
            self.fetchWeatherData(city: text)
        }
        textField.resignFirstResponder()
        return true
    }
    //MARK: UserDefaults to persist and load last searched city
    func saveLastSearchedCity(city: String){
        UserDefaults.standard.set(city, forKey: keyCity)
    }
    func getLastSavedCity() -> String? {
        return UserDefaults.standard.string(forKey: keyCity)
    }
}

