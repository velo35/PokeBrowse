//
//  ViewController.swift
//  PokeBrowse
//
//  Created by sdaniel on 11/24/17.
//  Copyright © 2017 sdaniel. All rights reserved.
//

import UIKit

let NUM_ITEMS = 10

class PokemonCell: UICollectionViewCell
{
    @IBOutlet var image: UIImageView?
    @IBOutlet var name: UILabel?
    
    override func prepareForReuse()
    {
        self.image?.image = nil
        self.name?.text = nil
    }
}

struct Pokemon
{
    var id = 0
    var name = ""
    var image: UIImage?
    var url = ""
}

class ViewController: UICollectionViewController {
    
    let urlSession = URLSession(configuration: .default)
    let API = "https://pokeapi.co/api/v2"
    
    var pokemon = [Pokemon]()
    
    @IBAction func handleReload(_ sender: UIBarButtonItem)
    {
        if let cachedPokemon = UserDefaults.standard.array(forKey: "cachedPokemon") {
            
            var pokemonArray = [Pokemon]()
            for entry in cachedPokemon {
                if let values = entry as? [String:String] {
                    let name = values["name"] ?? "<none>"
                    let url = values["url"] ?? "<none>"
                    let id = Int(values["id"] ?? "-1") ?? -1
                    
                    let pokemon = Pokemon(id: id, name: name, image: nil, url: url)
                    pokemonArray.append(pokemon)
                }
            }
            
            self.pokemon = pokemonArray
            self.collectionView?.reloadData()
            
            print("got \(self.pokemon.count) pokemon from cache")
            
            return
        }
        
        guard let url = URL(string: "\(API)/pokemon?limit=151") else { return }
        let dataTask = self.urlSession.dataTask(with: url) {
            [weak self]
            data, response, error in
            
            if let error = error {
                print("Error: \(error)")
            }
            else if let data = data {
                
                var json: Dictionary<String, Any>?
                
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
                }
                catch {
                    print("josn error: \(error)")
                }
                
                guard let results = json?["results"] as? Array<Any> else { return }
                
                var pokemonArray = [Pokemon]()
                var cachedPokemon = [[String:String]]()
                
                for (idx, entry) in results.enumerated() {
                    guard let values = entry as? Dictionary<String, Any> else { continue }
                    
                    let name = values["name"] as? String ?? "<none>"
                    let url = values["url"] as? String ?? "<none>"
                    
                    let pokemon = Pokemon(id: idx, name: name, image: nil, url: url)
                    pokemonArray.append(pokemon)
                    
                    cachedPokemon.append(["name": name, "id": "\(idx)", "url": url])
                }
                
                DispatchQueue.main.async {
                    self?.pokemon = pokemonArray
                    self?.collectionView?.reloadData()
                    
                    UserDefaults.standard.set(cachedPokemon, forKey: "cachedPokemon")
                    print("cached \(cachedPokemon.count) pokemon")
                }
            }
        }
        
        dataTask.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.operationQueue.maxConcurrentOperationCount = 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pokemon.count
    }
    
    private let operationQueue = OperationQueue()
//    private let cache = NSCache<String, UIImage>()
    private var cache = [Int:UIImage]()
    
    private func fetchImage(pokemon: Pokemon, callback: @escaping (UIImage) -> Void)
    {
        if let image = self.cache[pokemon.id] {
            callback(image)
            return
        }
 
        self.operationQueue.addOperation {
            [weak self] in
            
            let semaphore = DispatchSemaphore(value: 0)
        
            if let url = URL(string: pokemon.url) {
                print("fetching pokemon: \(pokemon.id)")
                let pokeinfo = self?.urlSession.dataTask(with: url) {
                    data, response, error in
                    
                    if let error = error {
                        print("pokemon error: \(error)")
                    }
                    else if let data = data {
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
                        if let json = json {
                            if let sprites = json?["sprites"] as? Dictionary<String, Any> {
                                if let front_default = sprites["front_default"] as? String {
                                    if let url = URL(string: front_default) {
                                        
                                        print("fetching pokemon image: \(pokemon.id)")
                                        let pokeimage = self?.urlSession.dataTask(with: url) {
                                            data, response, error in
                                            
                                            if let error = error {
                                                print("pokeimage error: \(error)")
                                            }
                                            else if let data = data {
                                                guard let image = UIImage(data: data) else { return }
                                                
                                                DispatchQueue.main.async {
                                                    self?.cache[pokemon.id] = image
                                                    callback(image)
                                                }
                                                
                                                semaphore.signal()
                                            }
                                        }
                                        
                                        pokeimage?.resume()
                                    }
                                }
                            }
                        }
                    }
                }

                pokeinfo?.resume()
                semaphore.wait()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pokemon", for: indexPath) as! PokemonCell
        
//        let hue = CGFloat(indexPath.item) / CGFloat(NUM_ITEMS)
//        cell.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)

        let pokemon = self.pokemon[indexPath.item]
        cell.name?.text = pokemon.name
        
        if let image = pokemon.image {
            cell.image?.image = image
        }
        else {
            
            self.fetchImage(pokemon: pokemon) {
                [weak cell, weak self, indexPath] image in
                
                guard let cell = cell else { return }
                
                if self?.collectionView?.indexPathForItem(at: cell.center) == indexPath {
                    cell.image?.image = image
                }
            }
        }
            
        return cell
    }
}

