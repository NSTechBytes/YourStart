$latitude = $RmAPI.VariableStr('latitude')
$longitude = $RmAPI.VariableStr('longitude')
$temperatureFormat = $RmAPI.VariableStr('WeatherFormat')  # Change to "F" for Fahrenheit

# Open-Meteo API URL for current weather
$apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true"

# Make a web request to fetch the weather data
$response = Invoke-RestMethod -Uri $apiUrl -Method Get

# Extract the temperature, windspeed, and weathercode
$temperature = $response.current_weather.temperature
$windspeed = $response.current_weather.windspeed
$weathercode = $response.current_weather.weathercode

# Convert temperature based on the desired format
if ($temperatureFormat -eq "F") {
    $temperature = [math]::Round($temperature * 9 / 5 + 32)  # Convert to Fahrenheit
    $degreeSymbol = "°F"
} else {
    $temperature = [math]::Round($temperature)  # Round for Celsius
    $degreeSymbol = "°C"
}

# Determine weather condition based on weathercode
$weatherCondition = ""

switch ($weathercode) {
    0 { $weatherCondition = "Clear" }
    1 { $weatherCondition = "Mainly clear" }
    2 { $weatherCondition = "Partly cloudy" }
    3 { $weatherCondition = "Overcast" }
    45 { $weatherCondition = "Fog" }
    48 { $weatherCondition = "Depositing rime fog" }
    51 { $weatherCondition = "Drizzle" }
    53 { $weatherCondition = "Light rain" }
    55 { $weatherCondition = "Moderate rain" }
    56 { $weatherCondition = "Heavy rain" }
    57 { $weatherCondition = "Showers" }
    61 { $weatherCondition = "Rain" }
    63 { $weatherCondition = "Heavy rain shower" }
    65 { $weatherCondition = "Thunderstorm" }
    80 { $weatherCondition = "Light snow" }
    81 { $weatherCondition = "Moderate snow" }
    82 { $weatherCondition = "Heavy snow" }
    default { $weatherCondition = "Unknown condition" }
}

# Output the results
#Write-Host "The current temperature at latitude $latitude and longitude $longitude is $temperature$degreeSymbol."
#Write-Host "The windspeed is $windspeed km/h."
#Write-Host "Current weather condition: $weatherCondition."

function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

rmbang "[!SetOption Weather_Image ImageName `"#@#Images\Weather Icons\$weatherCondition.png`"][!SetOption Temp_String Text `"$temperature$degreeSymbol`"][!SetOption Condition_String Text `"Condition:$weatherCondition`"][!SetOption Wind_Speed_String Text `"Wind Speed:$windspeed km/h`"][!UpdateMeter *]"