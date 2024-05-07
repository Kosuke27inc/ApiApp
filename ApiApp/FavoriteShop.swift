//
//  FavoriteShop.swift
//  ApiApp
//
//  Created by Kosuke Miyazaki on 2024/05/04.
//

import RealmSwift

class FavoriteShop: Object {
    // 店舗id
    @Persisted(primaryKey: true) var id = ""
    
    // 店舗名
    @Persisted var name = ""
    
    // 店舗画像URL
    @Persisted var logoImageURL = ""
    
    // クーポン画面URL
    @Persisted var couponURL = ""
    
    @Persisted var address: String  // 住所を保持するためのプロパティを追加
    
}
