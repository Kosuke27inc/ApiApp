//
//  ApiResponse.swift
//  ApiApp
//
//  Created by Kosuke Miyazaki on 2024/05/03.
//
import RealmSwift   // 追加

struct ApiResponse: Decodable {
    var results: Result
    
    struct Result: Decodable {
        var shop: [Shop]
        
        struct Shop: Decodable {
            var id: String
            var name: String
            var logo_image: String
            var coupon_urls: CouponUrls
            
            struct CouponUrls: Decodable {
                var pc: String
                var sp: String
            }
            
            // ここから
            var isFavorite: Bool {
                if try! Realm().object(ofType: FavoriteShop.self, forPrimaryKey: self.id) != nil {
                    return true
                } else {
                    return false
                }
            }
            // ここまで移動
        }
    }
}
