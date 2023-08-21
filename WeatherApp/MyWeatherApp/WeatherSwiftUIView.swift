//
//  WeatherSwiftUIView.swift
//  MyWeatherApp
//
//  Created by Sreenivas Babu on 8/20/23.
//

import SwiftUI

struct WeatherSwiftUIView: View {
    var description: String
    var body: some View {
        ZStack(alignment: .center) {
              Text(description)
                .foregroundColor(.blue)
                .font(.system(size: 18))
                .frame(width: 160, height: 40)
        }
    }
}

