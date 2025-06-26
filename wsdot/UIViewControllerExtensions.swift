
//

import Foundation
import GoogleMobileAds

extension UIViewController {

    func setStandardTableLayout(_ tableView: UITableView) {
        tableView.contentInset = UIEdgeInsets(top: 32,left: 0,bottom: 0,right: 0)
        tableView.tableFooterView = UIView()
    }
    
    func removeEmptyCells(_ tableView: UITableView) {
        tableView.tableFooterView = UIView()
    }
    
    func getFullWidthAdaptiveAdSize() -> AdSize {
      // Here safe area is taken into account, hence the view frame is used after the
      // view has been laid out.
      let frame = { () -> CGRect in
        if #available(iOS 11.0, *) {
          return view.frame.inset(by: view.safeAreaInsets)
        } else {
          return view.frame
        }
      }()
        return currentOrientationAnchoredAdaptiveBanner(width: frame.size.width)
    }

}
