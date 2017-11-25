//
//  ViewController.swift
//  PokeBrowse
//
//  Created by sdaniel on 11/24/17.
//  Copyright © 2017 sdaniel. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let hue = CGFloat(indexPath.item) / 1000.0
        cell.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(self.view.frame.width)")
    }

}

