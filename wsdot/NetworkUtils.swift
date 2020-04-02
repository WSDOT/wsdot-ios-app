
import Foundation

struct NetworkUtils {
    
    static func getNoCacheJSONRequest(forUrl: String) -> URLRequest {
        
        let url = NSURL(string: forUrl)
        var mutableURLRequest = URLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = "GET"
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        
        return mutableURLRequest
    }
}
