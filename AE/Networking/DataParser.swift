//
//  DataParser.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
    
    func parseModel(data: Data) -> Any? {
        switch self {
        //EP_Login Endpoint
        case is EP_Login:
            let endpoint = self as! EP_Login
            switch endpoint {
            case .userSignUp(_),
                 .verifyAccount(_),
                 .userLogin(_),
                 .editProfile(_):
                return JSONHelper<CommonModel<UserData>>().getCodableModel(data: data)?.data
            case .syncContacts(_):
                return JSONHelper<CommonModel<[ContactSynced]>>().getCodableModel(data: data)?.data
            default:
                return nil
            }
        //EP_Other Endpoint
        case is EP_Other:
            let endPoint = self as! EP_Other
            switch endPoint {
            case .nearByBusiness(_),
                 .followedBusinesses(_):
                return JSONHelper<CommonModel<BusineesPageObject>>().getCodableModel(data: data)?.data
            case .nearByFriends(_),
                 .userFriends(_):
                return JSONHelper<CommonModel<FriendPageObject>>().getCodableModel(data: data)?.data?.data
            case .businessDetail(_):
                return JSONHelper<CommonModel<Business>>().getCodableModel(data: data)?.data
            case .notifications(_):
                return JSONHelper<CommonModel<NotificationData>>().getCodableModel(data: data)?.data
            case .mapDataListing(_),
                 .homeSearch(_):
                return JSONHelper<CommonModel<MapData>>().getCodableModel(data: data)?.data
            case .appDefaults:
                return JSONHelper<CommonModel<AppDefault>>().getCodableModel(data: data)?.data
            case .objectListing(_):
                return JSONHelper<CommonModel<Objects>>().getCodableModel(data: data)?.data?.data
            case .packageListing(_):
                return JSONHelper<CommonModel<Packages>>().getCodableModel(data: data)?.data?.data
            case .getGallery(_):
                return JSONHelper<CommonModel<GalleryItems>>().getCodableModel(data: data)?.data?.data
            case .getProfile:
                return JSONHelper<CommonModel<UserData>>().getCodableModel(data: data)?.data
            case .uploadItem(let item):
                guard let shareType = item else { return nil }
                switch shareType {
                case .image(_):
                    return JSONHelper<CommonModel<[UploadedURL]>>().getCodableModel(data: data)?.data?.first?.normal
                case .video(_):
                    return JSONHelper<CommonModel<UploadedURL>>().getCodableModel(data: data)?.data?.normal
                }
            case .messageListing(_):
                return JSONHelper<CommonModel<MessageSubModel>>().getCodableModel(data: data)?.data?.data
            case .nearByBusinessFilters:
              return JSONHelper<CommonModel<[Filter]>>().getCodableModel(data: data)?.data
            default: return nil
            }
        default:
            return nil
        }
        
        
    }
}
