
class RefreshViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView()

    func showOverlay(_ view: UIView) {
    
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.gray
    
        if let splitView = self.splitViewController {
           
            if splitView .isCollapsed {
            
                activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
            
            } else {
            
                activityIndicator.center = CGPoint(x: view.center.x - splitView.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
                
            }
        } else {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
    
        view.addSubview(activityIndicator)
    
        activityIndicator.startAnimating()
    }

    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}

