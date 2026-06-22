// Data/Remote/DTOs/WeatherResponseDTO.swift
// WeatherCast App
// Codable DTOs mirroring the WeatherAPI JSON + domain mappers

import Foundation

// MARK: - Top-Level Response

struct WeatherResponseDTO: Codable {
    let location: LocationDTO
    let current: CurrentDTO
    let forecast: ForecastDTO
}

// MARK: - Location

struct LocationDTO: Codable {
    let name: String
    let country: String
    let localtime: String
}

// MARK: - Current Conditions

struct CurrentDTO: Codable {
    let temp_c: Double
    let feelslike_c: Double
    let humidity: Int
    let vis_km: Double
    let pressure_mb: Double
    let condition: ConditionDTO
}

// MARK: - Forecast Container

struct ForecastDTO: Codable {
    let forecastday: [ForecastDayDTO]
}

// MARK: - Forecast Day

struct ForecastDayDTO: Codable {
    let date: String
    let day: DayDTO
    let hour: [HourDTO]
}

// MARK: - Day Summary

struct DayDTO: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: ConditionDTO
}

// MARK: - Hourly

struct HourDTO: Codable {
    let time: String          // "2026-06-22 15:00"
    let temp_c: Double
    let condition: ConditionDTO
}

// MARK: - Condition

struct ConditionDTO: Codable {
    let text: String
    let icon: String          // "//cdn.weatherapi.com/weather/64x64/day/116.png"
}

// MARK: - City Search Result DTO

struct CitySearchResultDTO: Codable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double

    func toDomain() -> CitySearchResult {
        CitySearchResult(
            name: name,
            region: region,
            country: country,
            lat: lat,
            lon: lon
        )
    }
}

// MARK: - Domain Mappers

extension WeatherResponseDTO {

    /// Map the full API response → clean `WeatherEntity`.
    func toDomain(currentHour: Int) -> WeatherEntity {
        let forecastEntities = forecast.forecastday.enumerated().map { index, dayDTO in
            dayDTO.toDomain(index: index, currentHour: currentHour)
        }

        let today = forecast.forecastday.first

        return WeatherEntity(
            locationName: location.name,
            country: location.country,
            currentTemp: current.temp_c,
            feelsLike: current.feelslike_c,
            conditionText: current.condition.text,
            conditionIconURL: "https:" + current.condition.icon,
            humidity: current.humidity,
            visibilityKm: current.vis_km,
            pressureMb: current.pressure_mb,
            todayMaxTemp: today?.day.maxtemp_c ?? current.temp_c,
            todayMinTemp: today?.day.mintemp_c ?? current.temp_c,
            forecast: forecastEntities,
            localtime: location.localtime
        )
    }
}

extension ForecastDayDTO {

    func toDomain(index: Int, currentHour: Int) -> ForecastDayEntity {
        let label: String
        switch index {
        case 0:  label = "Today"
        case 1:  label = "Tomorrow"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: self.date) {
                let display = DateFormatter()
                display.dateFormat = "EEE"
                label = display.string(from: date)
            } else {
                label = date
            }
        }

        let hours = self.hour.enumerated().map { idx, hourDTO in
            hourDTO.toDomain(isFirst: index == 0 && idx == currentHour)
        }

        return ForecastDayEntity(
            dateString: date,
            dayLabel: label,
            maxTemp: day.maxtemp_c,
            minTemp: day.mintemp_c,
            conditionText: day.condition.text,
            conditionIconURL: "https:" + day.condition.icon,
            hours: hours
        )
    }
}

extension HourDTO {

    func toDomain(isFirst: Bool) -> HourEntity {
        // Extract the hour component for display ("3PM", "Now", etc.)
        let parts = time.split(separator: " ")
        let timeLabel: String
        if isFirst {
            timeLabel = "Now"
        } else if parts.count > 1 {
            let timePart = String(parts[1])             // "15:00"
            let components = timePart.split(separator: ":")
            if let hourInt = components.first.flatMap({ Int($0) }) {
                if hourInt == 0 {
                    timeLabel = "12AM"
                } else if hourInt < 12 {
                    timeLabel = "\(hourInt)AM"
                } else if hourInt == 12 {
                    timeLabel = "12PM"
                } else {
                    timeLabel = "\(hourInt - 12)PM"
                }
            } else {
                timeLabel = timePart
            }
        } else {
            timeLabel = time
        }

        return HourEntity(
            timeLabel: timeLabel,
            tempC: temp_c,
            conditionIconURL: "https:" + condition.icon,
            conditionText: condition.text
        )
    }
}
