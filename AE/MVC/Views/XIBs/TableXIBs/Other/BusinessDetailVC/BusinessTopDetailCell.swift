//
//  BusinessTopDetailCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 13/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class BusinessTopDetailCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgLogo: UIImageView!
  @IBOutlet weak var lblBusinessName: UILabel!
  @IBOutlet weak var lblBusinessSubtitle: UILabel!
  @IBOutlet weak var lblBranchesCount: UILabel!
  @IBOutlet weak var lblBranchesTitle: UILabel!
  @IBOutlet weak var viewBranches: UIView!
  @IBOutlet weak var lblExperienceTitle: UILabel!
  @IBOutlet weak var lblDesc: UILabel!
  @IBOutlet weak var imgMap: UIImageView!
  @IBOutlet weak var btnContact: UIButton!
  @IBOutlet weak var btnFollow: UIButton!
  @IBOutlet weak var lblAddress: UILabel!
  @IBOutlet weak var branchWidth: NSLayoutConstraint!
  @IBOutlet weak var lblTitleHeight: NSLayoutConstraint!
  @IBOutlet weak var lblSubTitleHeight: NSLayoutConstraint!
  
  var isNavigatedViaBranches: Bool? 
  
  var item: Any? {
    didSet {
      let obj = item as? Business
      imgLogo.setImageKF(obj?.logoUrl?.thumbnail)
      lblBranchesCount.text = /obj?.noOfBranches == 0 ? "" : String(/obj?.noOfBranches)
      lblBranchesTitle.text = (/obj?.noOfBranches).branchesTitle
      viewBranches.isHidden = /isNavigatedViaBranches || /obj?.noOfBranches == 0
      branchWidth.constant = (/isNavigatedViaBranches || /obj?.noOfBranches == 0) ? 0 : 80
      lblDesc.text = /obj?.description
      btnFollow.setTitle((/obj?.isFollowing).followUnfollowText, for: .normal)
      lblAddress.text = /obj?.addressDetails?.address
      
      lblBusinessName.text = /obj?.name
      lblTitleHeight.constant = (/obj?.name).height(constraintedWidth: lblBusinessName.frame.width, font: Fonts.SFProDisplayBold.ofSize(24)) + 8.0
      
      lblBusinessSubtitle.text = /obj?.businessType
      lblSubTitleHeight.constant = (/obj?.businessType).height(constraintedWidth: lblBusinessSubtitle.frame.width, font: Fonts.SFProTextMedium.ofSize(12))
      
      viewBranches.addTapGestureRecognizer { [weak self] in
        let destVC = StoryboardScene.Other.ListingVC.instantiate()
        destVC.listingType = .BusinessBranches(of: self?.item as? Business)
        UIApplication.topVC()?.pushVC(destVC)
      }
    }
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Contact
      let business = (item as? Business)
      UIApplication.topVC()?.actionSheet(for: [VCLiteral.CONTACT_EMAIL.localized, VCLiteral.CONTACT_CALL.localized], title: nil, message: nil, tapped: { (actionTapped) in
        switch /actionTapped {
        case VCLiteral.CONTACT_EMAIL.localized:
          let email = /business?.email
          (UIApplication.topVC() as? BusinessDetailVC)?.phoneServices.mail(to: [email])
        case VCLiteral.CONTACT_CALL.localized:
          let phoneNumber = "+\(/business?.contactDetails?.countryCode)-\(/business?.contactDetails?.phoneNo))"
          (UIApplication.topVC() as? BusinessDetailVC)?.phoneServices.call(to: phoneNumber)
        default:
          break
        }
      })
    case 1: // Follow
      followUnfollowAPI()
    case 2: // Directions
      let business = (item as? Business)
      UIApplication.topVC()?.navigate(lat: /business?.addressDetails?.coordinates?.last, lng: /business?.addressDetails?.coordinates?.first)
    default:
      break
    }
  }
  
  private func followUnfollowAPI() {
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
      return
    }
    
    btnFollow.isUserInteractionEnabled = false
    let obj = item as? Business
    guard let action = obj?.isFollowing?.actionToAPI else { return }
    
    if action == .UNFOLLOW {
      btnFollow.isUserInteractionEnabled = true
      let popUpVC = StoryboardScene.PopUp.UnfollowPopUpVC.instantiate()
      popUpVC.business = (item as? Business)
      popUpVC.didTapYes = { [weak self] in
        self?.apiFollowUnfollow(action: action)
      }
      UIApplication.topVC()?.presentPopUp(popUpVC)
    } else {
      apiFollowUnfollow(action: action)
    }
    
  
  }
  
  private func apiFollowUnfollow(action: FollowAction) {
    let obj = item as? Business
    EP_Other.followUnfollowBusiness(id: obj?._id, action: action).request(success: { [weak self] (response) in
      self?.btnFollow.isUserInteractionEnabled = true
      (self?.item as? Business)?.isFollowing?.toggle()
      (UIApplication.topVC() as? BusinessDetailVC)?.business = self?.item as? Business
      (UIApplication.topVC() as? BusinessDetailVC)?.businessUpdated?(self?.item as? Business)
      UserPreference.shared.updateFollowingCount(/(self?.item as? Business)?.isFollowing)
      (self?.superview as? UITableView)?.reloadData()
    }) { [weak self] (error) in
      self?.btnFollow.isUserInteractionEnabled = true
    }
  }
}
