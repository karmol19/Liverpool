//
//  ViewController.swift
//  Demo
//
//  Created by Carlos Molina on 04/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var arrayProduct:Array<Product>?
    var arraySearch:Array<Search>?
    var cellSize = CGSize()
    var iphoneCollectionCell = 2
    var ipadCollectionCell = 4
    //MARK:LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>.init(entityName: DataBaseEntity.Product)
        fetchRequest.includesSubentities = false
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        arrayProduct = DataBaseManager.sharedInstance.fetchRequest(fetchRequest: fetchRequest, context: DataBaseManager.sharedInstance.mainContext) as? Array<Product>
        collectionView.register(UINib.init(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateCellSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateCellSize()
    }
    //MARK:CellSize

    func calculateCellSize()
    {
        var screenPortraint = true
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeLeft || orientation == .landscapeRight
        {
            screenPortraint = false
        }
        let width = (screenPortraint) ? self.collectionView.bounds.size.width : self.collectionView.bounds.size.height
        var cellwidthconstant = CGFloat(0)
        if UI_USER_INTERFACE_IDIOM() == .phone
        {
            cellwidthconstant = (width - (CGFloat(8)*(CGFloat(iphoneCollectionCell)+CGFloat(1))))/CGFloat(iphoneCollectionCell)
        }
        else
        {
                cellwidthconstant = (width - (CGFloat(8)*(CGFloat(ipadCollectionCell)+CGFloat(1))))/CGFloat(ipadCollectionCell)
 
        }
        cellSize  = CGSize(width: cellwidthconstant, height: cellwidthconstant)

    }
    
    //MARK:UICollection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayProduct == nil || arrayProduct?.count == 0
        {
            self.collectionView.isHidden = true
        }
        else
        {
            self.collectionView.isHidden = false
        }
        return arrayProduct?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        let product = arrayProduct![indexPath.row]
        cell.product = product
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return cellSize
    }
    
    //MARK:UISearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        let trimmedString = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let textSearch = searchBar.text
        if ((textSearch?.count)! > 0 && (trimmedString?.count)! > 0)
        {
            
            var search = DataBaseManager.sharedInstance.object(predicate: NSPredicate(format: "title == %@",textSearch!), entity: DataBaseEntity.Search) as? Search
            if search == nil
            {
                search = Search.init(entity: DataBaseManager.sharedInstance.entityDescription(entityName: DataBaseEntity.Search)!, insertInto: DataBaseManager.sharedInstance.mainContext)
                search?.title = textSearch
                search?.date = Date() as NSDate
                DataBaseManager.sharedInstance.saveContext()
            }
            arrayProduct = Array(search?.results ?? NSSet()) as? Array<Product>
            updateResults()
            let service = ProductSearchServiceObject.init(search: search!)
            service.startDownload { (json, error) in
                if error == nil
                {
                    self.arrayProduct = Array(search?.results ?? NSSet()) as? Array<Product>
                    self.updateResults()

                }
            }
            
        }
        searchDisplayController?.isActive = false
        view.endEditing(true)

    }
    //    MARK: updateResults
    func updateResults()
    {
        collectionView.reloadData()
    }
    
    //MARK:UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>.init(entityName: DataBaseEntity.Search)
        fetchRequest.includesSubentities = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title contains[c] %@",searchBar.text ?? "")
        arraySearch = DataBaseManager.sharedInstance.fetchRequest(fetchRequest: fetchRequest, context: DataBaseManager.sharedInstance.mainContext) as? Array<Search>
        return arraySearch!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")
        if  cell == nil
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "SearchCell")
        }
        let search = arraySearch![indexPath.row]
        cell?.textLabel?.text = search.title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if ((arraySearch != nil) && (arraySearch?.count)! > 0)
        {
            let search = arraySearch![indexPath.row]
            searchBar.text = search.title
            searchBar.delegate?.searchBarSearchButtonClicked!(searchBar)
        }
        
    }
    
}

