//
//  InviteFriendsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class InviteFriendsVC: ButtonBarPagerTabStripViewController {

  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnSkip: UIButton!
  
  private var tabs = [StoryboardScene.GetStarted.ContactsFacebookVC.instantiate(),
                       StoryboardScene.GetStarted.ContactsFacebookVC.instantiate()]
  var navigatedFrom: InviteNavigation = .FromSignUp
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnBack.isHidden = navigatedFrom.isBackHidden
    btnSkip.isHidden = navigatedFrom.isSkipHidden
    setupBarView()
    setupCell()
    reloadPagerTabStripView()
  }
  
  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    for (index, item) in tabs.enumerated() {
      item.itemInfo.title = /InviteFriendTab(rawValue: index)?.title
      item.vcType = InviteFriendTab(rawValue: index) ?? .Contacts
    }
    return tabs
  }
 
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back Action
      popVC()
    case 1: //Skip Action
      CommonFuncs.shared.storyboardReInstantiateFor(.SuccessSignUp)
    default:
      break
    }
  }
  
}

//MARK:- XLPager Setup Functions
extension InviteFriendsVC {
  private func setupBarView(){
    settings.style.buttonBarBackgroundColor = UIColor.clear
    settings.style.buttonBarItemFont = Fonts.SFProTextBold.ofSize(14)
    settings.style.buttonBarItemTitleColor = Color.textBlue.value
    settings.style.selectedBarHeight = 2.0
    settings.style.buttonBarItemBackgroundColor = UIColor.clear
    settings.style.buttonBarItemsShouldFillAvailableWidth = false
    settings.style.selectedBarVerticalAlignment = .middle
    buttonBarView.selectedBar.backgroundColor = Color.textBlue.value
    buttonBarView.backgroundColor = UIColor.clear
    reloadPagerTabStripView()
  }
  
  private func setupCell(){
    changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
      guard changeCurrentIndex == true else { return }
      oldCell?.label.textColor = Color.textBlack40.value
      oldCell?.label.font = Fonts.SFProTextRegular.ofSize(14.0)
      newCell?.label.textColor = Color.textBlue.value
      newCell?.label.font = Fonts.SFProTextBold.ofSize(14.0)
    }
  }
}
