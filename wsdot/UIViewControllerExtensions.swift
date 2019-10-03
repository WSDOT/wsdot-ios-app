
//

import Foundation

extension UIViewController {

    func setStandardTableLayout(_ tableView: UITableView) {
        tableView.contentInset = UIEdgeInsets(top: 32,left: 0,bottom: 0,right: 0)
        tableView.tableFooterView = UIView()
    }
    
    func removeEmptyCells(_ tableView: UITableView) {
        tableView.tableFooterView = UIView()
    }

}
