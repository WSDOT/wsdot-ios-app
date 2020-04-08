
import Foundation

struct NetworkUtils {
    
    static func getJSONRequestNoLocalCache(forUrl: String) -> URLRequest {
        
        let url = NSURL(string: forUrl)
        var mutableURLRequest = URLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = "GET"
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        return mutableURLRequest
    }
}
