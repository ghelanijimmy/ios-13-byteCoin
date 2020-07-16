//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func updateCoinRate(_ price: String, _ currency: String)
    func onErrorCoinData(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "899FE7BA-EDEB-4274-B186-380DB51DC5B1"
    var currency = ""
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    
    mutating func getCoinPrice(for currency: String){
        self.currency = currency
        performRequest(with: "\(baseURL)/\(currency)?apikey=\(apiKey)")
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.onErrorCoinData(error: error!)
                }
                
                if let safeData = data {
                    if let coinData = parseJSON(safeData) {
                        self.delegate?.updateCoinRate(String(format: "%.2f", coinData.rate), self.currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinData? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            print(rate)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
}
