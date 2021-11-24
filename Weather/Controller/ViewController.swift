//
//  ViewController.swift
//  Weather
//
//
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count // You will replace this with arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(arrCurrentWeather[indexPath.row].cityInfoName),  \(arrCurrentWeather[indexPath.row].temp)°C &  \(arrCurrentWeather[indexPath.row].weatherText)"
        // replace this with values from arrCurrentWeather array
        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCityInfo.removeAll()
            self.arrCurrentWeather.removeAll()
            getAllCurrentWeather(Array(cities)).done { currentWeather in
                
            self.tblView.reloadData()
            }
            .catch { error in
               print(error)
            }
       }catch{
           print("Error in reading Database \(error)")
       }
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ... cities.count - 1 {
                promises.append( getCurrentWeather(cities[i].key, cities[i].localizedName) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    
    func getCurrentWeather(_ cityKey : String, _ cityName : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = currentConditionURL + cityKey + "?apikey=" + apiKey // build URL for current weather here
                
                AF.request(url).responseJSON { [self] response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let weatherData = JSON( response.data!).array
                    
                    guard let weatherInfo = weatherData!.first else {seal.fulfill(JSON().rawValue as! CurrentWeather)
                        return
                    }
                  
                    let currentWeather = CurrentWeather()
                    
                    currentWeather.cityInfoName = cityName
                    currentWeather.weatherText = weatherInfo["WeatherText"].stringValue
                    currentWeather.temp = ((weatherInfo["Temperature"])["Metric"])["Value"].intValue
                    arrCurrentWeather.append(currentWeather)
                    
                    seal.fulfill(currentWeather)
                }
            }
    }

}

