//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Ashish Ashish on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import PromiseKit
import RealmSwift

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
   
    let arr = ["Seattle WA, USA", "Seaside CA, USA"]
    
    
    var arrCityInfo : [CityInfo] = [CityInfo]()
    let cityInfo = CityInfo()

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text =  arrCityInfo[indexPath.row].localizedName// rr[indexPath.row]//[indexPath.row] // You will change this to getr values from arrCityinfo and assign text
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addCitiesToDB(cityInfo)
        print(cityInfo)
    }
    
    func addCitiesToDB(_ cityInfor : CityInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(cityInfor, update: .modified)
            }
        }catch{
            print("Error in DB \(error)")
        }
    }
    
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String)  -> Promise <CityInfo> {
        return Promise<CityInfo> { seal -> Void in
        // Network call from there
        let url = getSearchURL(searchText)
        
    
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            
            let locations = JSON( response.data!).array
            
            guard var cityValues = locations!.first else {seal.fulfill(JSON().rawValue as! CityInfo)
                return
            }
            
            self.cityInfo.key = cityValues["Key"].stringValue
            self.cityInfo.type = cityValues["Type"].stringValue
            self.cityInfo.localizedName = cityValues["LocalizedName"].stringValue
            self.cityInfo.countryLocalizedName = cityValues["CountryLocalizedName"].stringValue
            self.cityInfo.administrativeID = cityValues["AdministrativeID"].stringValue
         
            seal.fulfill (self.cityInfo)
            self.arrCityInfo.append(self.cityInfo)
            //seal.fulfill (JSON(rawValue: self.arrCityInfo) ?? JSON())
            
            self.tblView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
}
