# WeatherApp

## Overview
App shows user weather conditions for his location. User can also change the location he wishes to see the weather condition for. Every location is also presented with an image received from GooglePlaces API. If the image is not available, placeholder image is presented.


## Implemented bits 
⋅⋅* use of PageViewController for little introduction
⋅⋅* use UserDefault for saving whether app has been previously launched on the device - set root controller accordingly
⋅⋅* use animation to make UX feel better
⋅⋅* use CoreLocation and CLLocationManager for getting user's location
⋅⋅* use PromiseKit, Alamofire, SwiftyJSON for fetching and parsing data
⋅⋅* use delegation pattern, create custom protocol 
⋅⋅* use openWeatherMaps for weather data
⋅⋅* use googlePlaces for pictures of places
⋅⋅* use googlePlaces for pictures of places
⋅⋅* handle the case when user did not give permission to use location to the app - redirect user to settings
⋅⋅* fetching data while app is in the background state with background 
⋅⋅* caching images using NSCache
⋅⋅* saving images to filesystem
