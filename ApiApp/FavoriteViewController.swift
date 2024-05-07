//
//  FavoriteViewController.swift
//  ApiApp
//
//  Created by Kosuke Miyazaki on 2024/05/03.
//

import UIKit
import RealmSwift       // 追加
import AlamofireImage   // 追加
import SafariServices

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let favoriteShop = favoriteArray[indexPath.row]
        let url = URL(string: favoriteShop.couponURL)!
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }
    
    var favoriteArray = try! Realm().objects(FavoriteShop.self) // 追加
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        // ここから
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)!
        let favoriteShop = favoriteArray[indexPath.row]
        
        let alert = UIAlertController(title: favoriteShop.name, message: "この店舗をお気に入りから削除してもよろしいですか?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            print("「\(favoriteShop.name)」をお気に入りから削除します")
            try! self.realm.write {
                self.realm.delete(favoriteShop)
            }
            self.tableView.reloadData()
            if self.favoriteArray.count == 0 {
                self.statusLabel.text = "お気に入りはまだ登録されていません"
            } else {
                self.statusLabel.text = ""
            }
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        // ここまで追加
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ここから
        tableView.delegate = self
        tableView.dataSource = self
        // ここまで追加
    }
    
    // ここから
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        if favoriteArray.count == 0 {
            statusLabel.text = "お気に入りはまだ登録されていません"
        } else {
            statusLabel.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ShopCell
        let favoriteShop = favoriteArray[indexPath.row]
        let url = URL(string: favoriteShop.logoImageURL)!
        cell.logoImageView.af.setImage(withURL: url)
        cell.shopNameLabel.text = favoriteShop.name
        cell.addressLabel.text = favoriteShop.address  // ここを修正
        return cell
    }
    // ここまで追加
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
