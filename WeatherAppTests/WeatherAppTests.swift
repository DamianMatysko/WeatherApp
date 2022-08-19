//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Damián Matysko on 8/10/22.
//

import XCTest
@testable import WeatherApp

class WeatherAppTests: XCTestCase {
    var sessionConfigurationMocked: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockUrlProtocol.self]
        return config
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFeatchWeather() async throws {
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url,
                  url.absoluteString.contains("weather?q") else {
                throw WeatherError.invalidURL
            }
            
            var jsonData: Data?
            let bundle = Bundle(for: type(of: self))
            if let path = bundle.url(forResource: "Weather", withExtension: "json"){
                if let data = try? Data(contentsOf: path) {
                    jsonData = data
                }
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return(response, jsonData)
        }
        //given
        let api = WeatherAPI(urlSession: URLSession(configuration: sessionConfigurationMocked))
        //when
        let response = try? await api.featchWeatherOLD(for: "Kosice")
        //then
        XCTAssertNotNil(response)
        XCTAssert(!(response?.weather.isEmpty ?? true), "Response weather should not be empty")
    }
    
    func testFeatchWeatherBad() async throws {
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url,
                  url.absoluteString.contains("weather?q") else {
                throw WeatherError.invalidURL
            }
            
            var jsonData: Data?
            let bundle = Bundle(for: type(of: self))
            if let path = bundle.url(forResource: "WeatherBad", withExtension: "json"){
                if let data = try? Data(contentsOf: path) {
                    jsonData = data
                }
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return(response, jsonData)
        }
        //given
        let api = WeatherAPI(urlSession: URLSession(configuration: sessionConfigurationMocked))
        //when
        do {
            let response = try? await api.fetchWeather(for: "Kosice")
        } catch let apiError {
            //then
            XCTAssertNotNil(apiError)
        }
    }
    
    /// Test to get forecast from api
    func testFetchForecast() async throws {
        
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url,
                  url.absoluteString.contains("forecast?q") else {
                throw WeatherError.invalidURL
            }
            
            var jsonData: Data?
            let bundle = Bundle(for: type(of: self))
            if let path = bundle.url(forResource: "Forecast", withExtension: "json"){
                if let data = try? Data(contentsOf: path) {
                    jsonData = data
                }
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return(response, jsonData)
        }
        //given
        let api = WeatherAPI(urlSession: URLSession(configuration: sessionConfigurationMocked))
        //when
        
        let response = try? await api.fetchForecast(for: "London")
        
        //then
        XCTAssertNotNil(response)
        XCTAssert(!(response?.list.isEmpty ?? true), "Response weather should not be empty")
    }
    
    func testViewModelFetchWeather() async throws {
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw WeatherError.invalidURL
            }
            
            var jsonData: Data?
            let bundle = Bundle(for: type(of: self))
            var fileNmae = "Weather"
            if !url.absoluteString.contains("weather?q"){
                fileNmae = "Forecast"
            } else {
                throw WeatherError.invalidURL
            }
            if let path = bundle.url(forResource: fileNmae, withExtension: "json"){
                if let data = try? Data(contentsOf: path) {
                    jsonData = data
                }
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return(response, jsonData)
        }
        // give
        let api = WeatherAPI(urlSession: URLSession(configuration: sessionConfigurationMocked))
        let viewModel: WeatherViewModel =
            .init(weatherApi: api, city: "Test")
        let viewDetailModel: WeatherDetailViewModel =
            .init(databaseManager: DatabaseManager(), weatherResposne: WeatherResponse(weather: [], coord: Coord(lat: 48, lon: 48), main: Main(temp: 54, tempMin: 54, tempMax: 54, humidity: 34), name: "String"))
        // when
        await viewModel.fetch()
        // then
        XCTAssertNotNil(viewModel.weather)
        if case let .loaded(response) = viewModel.weather {
            XCTAssert(response.name == "Kosice")
        }
        XCTAssertNotNil(viewDetailModel.forecast)
    }
    
    func testForecastDay() async throws {
        //given
        let forecast = Forecast.mock()
        //when
        let day = forecast.day
        let nowDay = Date().formatted(.dateTime.day())
        //then
        XCTAssertEqual("\(nowDay)", day)
    }
    
    func testForecastMonth() async throws {
        let forecast = Forecast.mock()
        //when
        let month = forecast.month
        let novMonth = Date().formatted(.dateTime.month(.abbreviated))
        //then
        XCTAssertEqual("\(novMonth)", month)
    }
    
    func testForecastHour() async throws {
        let forecast = Forecast.mock()
        //when
        let hour = forecast.hour
        let nowHour = Date().formatted(.dateTime.hour(.twoDigits(amPM: .narrow)).minute())
        //then
        XCTAssertEqual("\(nowHour)", hour)
    }
    
}
