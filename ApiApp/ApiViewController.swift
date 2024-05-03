//
//  ApiViewController.swift
//  ApiApp
//
//  Created by Kosuke Miyazaki on 2024/05/02.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift

struct Shop {
    let id: String
    let name: String
    let logo_image: String
    let coupon_urls: ApiResponse.Result.Shop.CouponUrls
    var isFavorite: Bool
    
    init(apiShop: ApiResponse.Result.Shop, isFavorite: Bool) {
        self.id = apiShop.id
        self.name = apiShop.name
        self.logo_image = apiShop.logo_image
        self.coupon_urls = apiShop.coupon_urls
        self.isFavorite = isFavorite
    }
}

class ApiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var shopArray: [Shop] = []
    var apiKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let filePath = Bundle.main.path(forResource: "ApiKey", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)!
        apiKey = plist["key"] as! String
        
        updateShopArray()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        updateShopArray()
    }
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)!
        let shop = shopArray[indexPath.row]
        
        if shop.isFavorite {
            print("「\(shop.name)」をお気に入りから削除します")
            try! realm.write {
                let favoriteShop = realm.object(ofType: FavoriteShop.self, forPrimaryKey: shop.id)!
                realm.delete(favoriteShop)
            }
        } else {
            print("「\(shop.name)」をお気に入りに追加します")
            try! realm.write {
                let favoriteShop = FavoriteShop()
                favoriteShop.id = shop.id
                favoriteShop.name = shop.name
                favoriteShop.logoImageURL = shop.logo_image
                if shop.coupon_urls.sp == "" {
                    favoriteShop.couponURL = shop.coupon_urls.pc
                } else {
                    favoriteShop.couponURL = shop.coupon_urls.sp
                }
                realm.add(favoriteShop)
            }
        }
        tableView.reloadData()
    }
    
    func updateShopArray() {
        let parameters: [String: Any] = [
            "key": apiKey,
            "start": 1,
            "count": 20,
            "keyword": "ランチ",
            "format": "json"
        ]
        
        AF.request("https://webservice.recruit.co.jp/hotpepper/gourmet/v1/", method: .get, parameters: parameters).responseDecodable(of: ApiResponse.self) { response in
            if self.tableView.refreshControl!.isRefreshing {
                self.tableView.refreshControl!.endRefreshing()
            }
            
            switch response.result {
            case .success(let apiResponse):
                print("受信データ: \(apiResponse)")
                self.shopArray = apiResponse.results.shop.map { apiShop in
                    let isFavorite = self.realm.object(ofType: FavoriteShop.self, forPrimaryKey: apiShop.id) != nil
                    return Shop(apiShop: apiShop, isFavorite: isFavorite)
                }
                self.statusLabel.text = ""
            case .failure(let error):
                print(error)
                self.shopArray = []
                self.statusLabel.text = "データの取得が失敗しました"
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ShopCell
        let shop = shopArray[indexPath.row]
        let url = URL(string: shop.logo_image)!
        cell.logoImageView.af.setImage(withURL: url)
        cell.shopNameLabel.text = shop.name
        
        let starImageName = shop.isFavorite ? "star.fill" : "star"
        let starImage = UIImage(systemName: starImageName)?.withRenderingMode(.alwaysOriginal)
        cell.favoriteButton.setImage(starImage, for: .normal)
        
        return cell
    }
}
