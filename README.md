# MyWeatherApp
OpenWeatherApp
Coding Challenge: Weather
Below are the details needed to construct a weather based app where users can look up weather for a city.
Public API Create a free account at openweathermap.org. Just takes a few minutes. Full documentation for the service below is on their site, be sure to take a few minutes to understand it.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid={API key}
Built-in geocoding
Please use Geocoder API if you need automatic convert city names and zip-codes to geo coordinates and the other way around.
Please note that API requests by city name, zip-codes and city id have been deprecated. Although they are still available for use, bug fixing and updates are no longer available for this functionality.
Built-in API request by city name
You can call by city name or city name, state code and country code. Please note that searching by states available only for the USA locations.
API call
https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
https://api.openweathermap.org/data/2.5/weather?q={city name},{country code}&appid={API key}
https://api.openweathermap.org/data/2.5/weather?q={city name},{state code},{country code}&appid={API key}
 
You will also need icons from here:
http://openweathermap.org/weather-conditions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
Requirements
These requirements are rather high-level and vague. If there are details I have omitted, it is because I will be happy with any of a wide variety of solutions. Don't worry about finding "the" solution.
1. Create a browser or native-app-based application to serve as a basic weather app.
2. Search Screen
    * Allow customers to enter a US city
    * Call the openweathermap.org API and display the information you think a user would be interested in seeing. Be sure to has the app download and display a weather icon.
    * Have image cache if needed
3. Auto-load the last city searched upon app launch.
4. Ask the User for location access, If the User gives permission to access the location, then retrieve weather data by default
