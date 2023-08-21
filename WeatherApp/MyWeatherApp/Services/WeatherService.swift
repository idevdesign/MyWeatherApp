//
//  WeatherService.swift
//  MyWeatherApp
//
//  Created by Sreenivas Babu on 8/20/23.
//

import Foundation
import UIKit

// MARK: Weather API calls


enum WeatherError: Error {
    case networkError
    case invalidUrl
    case cityNotFound
    case jsonDataError
    case imageError
}
class WeatherService {
    
    //singleton - can be improved..
    static let shared = WeatherService()
    

    func getWeather(city: String, isMetric:Bool = false, completion: @escaping ((Weather?, WeatherError?) -> ()) ){
        
        //get the units metric
        let unitsString = isMetric ? unitsOptionMetric : unitsOptionImperial
        
        let weatherAPIURL = "\(k_ow_api_url)?q=\(city)&appid=\(k_api_key)&units=\(unitsString)"

        guard let url = URL(string: weatherAPIURL) else {
            print("Invalid URL")
            completion(nil, .invalidUrl)
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    guard let weatherArray = json["weather"] as? [[String: Any]],
                       let weather = weatherArray.first,
                       let main = json["main"] as? [String: Any],
                       let temperature = main["temp"] as? Double,
                       let iconName = weather["icon"] as? String,
                       let description = weather["description"] as? String else {
                        completion(nil, .cityNotFound)
                        return
                      }
                     let iconURLString = "\(k_icon_base_url)\(iconName)@2x.png"
                     let weatherObject = Weather(temp: temperature, icon: iconURLString, description: description)
                     completion(weatherObject, nil)
                } else {
                    print("Error while getting json data")
                    completion(nil, .jsonDataError)
                }
            }
            if let error = error {
                print("Error while getting weather data: \(error)")
                completion(nil, .networkError)
            }
        }.resume()
    }
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}


//JSON Response
//
//{
//    "coord":
//    {
//    "lon":-84.2941,
//    "lat":34.0754
//    },
//     "weather":
//        [
//            {
//                "id":800,
//                "main":"Clear",
//                "description":"clear sky",
//                "icon":"01d"
//            }
//        ],
//    "base":
//    "stations",
//    "main":
//    {
//        "temp":30.27,
//        "feels_like":33.14,
//        "temp_min":27.66,
//        "temp_max":32.44,
//        "pressure":1022,
//        "humidity":59},
//        "visibility":10000,
//        "wind":
//         {
//             "speed":0.45,
//             "deg":258,
//             "gust":1.34},
//          "clouds":
//         {
//             "all":0
//
//         },"dt":1692549472,
//        "sys":
//        {
//            "type":2,
//            "id":2032097,
//            "country":"US",
//            "sunrise":1692529333,
//            "sunset":1692577162
//        },
//       "timezone":-14400,
//        "id":4179574,
//        "name":"Alpharetta",
//        "cod":200
