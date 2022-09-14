//
//  TestViewController.swift
//  iOS_Lab001
//
//  Created by 유현지 on 2022/09/14.
//

import UIKit



/*
 Result Type 원형
 
 A value that represents either a success or a failure, including an
 associated value in each case.
 
 성공과 실패를 나타내는 값.
 각 경우에 연관된 값도 포함한다.
 
 @frozen public enum Result<Success, Failure> where Failure : Error {
 
 /// A success, storing a `Success` value.
 case success(Success)
 
 /// A failure, storing a `Failure` value.
 case failure(Failure)
 
 */

class SinsangMarketViewController: UIViewController {
    
    // 기존 신상마켓
    enum EAPIResult {
        case success(_ response:Any? = nil)
        case failure(_ failType: EAPIFailType)
        
        var succeed:Bool {
            switch self {
            case .failure(_):
                return false
            default:
                return true
            }
        }
        
        var notConnectedToInternet:Bool {
            switch self {
            case .failure(_):
                return true
            default:
                return false
            }
        }
    }
    
    enum EAPIFailType: Error {
        case unknow
        case network
    }
    
    enum HTTPMethod {
        case get
        case put
    }
    
    // 기존 신상마켓 - ASModule
    func request(method: HTTPMethod, result: @escaping (EAPIResult) -> Void) {
        
        // AF 통신
        Alamofire.request(request).responseJSON { [weak self]
            response in
            
            guard let self = self, let data = response.data else { return }
            
            var responseModel: ASResponseCodable?
            do {
                // 통신 후 받은 데이터를 디코딩
                let decode = JSONDecoder()
                responseModel = try decoder.decode(ASResponseCodable.self, from: data)
            }
            
            // 각 API 클래스에서 매핑
            self.responseValue(self.setResponseMeta(response.result.value))
            
            // 성공했다면,
            if responseModel.meta.success == true {
                DispatchQueue.main.async {
                    // 정의한 EAPIResult Enum에 success 값을 던진다.
                    result(.success(response.result.value))
                }
            }
            // 실패했다면,
            else {
                // 정의한 EAPIResult Enum에 실패를 던진다.
                result(.failure(.unknow))
            }
        }
    }

    // Result를 사용하면 기존에 정의했던 EAPIResult는 쓰지 않아도 된다.
    func requestResult<T: Codable>(method: HTTPMethod, completion: @escaping (Result<T, EAPIFailType>) -> Void) {
        
        // AF 통신
        Alamofire.request(request).responseJSON { [weak self]
            response in
            
            guard let self = self, let data = response.data else { return }
            
            var responseModel: T?
            do {
                // 통신 후 받은 데이터를 디코딩
                let decode = JSONDecoder()
                responseModel = try decoder.decode(T.self, from: data)
                completion(.success(responseModel))
            } catch {
                completion(.failure(.unknow))
            }
        }
    }
    
    struct iOSPart: Codable {
        var name: String
    }
    
    func fetch() {
        self.requestResult(method: .get, completion: { (result: Result<iOSPart, EAPIFailType>) in
            
            // success 하면 Codable을 채택하고 있는 iOSPart를 데이터로 받아와서 처리한다.
            
            switch result {
            case .success(let data):
                print(data.name)
            case .failure(let failure):
                if failure == .network {
                    print("네트워크 오류")
                } else {
                    print("알 수 없는 오류")
                }
            }
        })
    }
}

/*
 Alamofire도 Swift 5.0 전에는 Result를 직접 만들어서 사용하고 있었기 때문에,
 라이브러리 버전 올리면서 Alamofire는 어떤식으로 변경됐을지 보는것이...잼쓹듯...
 
 public enum Result<Value> {
     case success(Value)
     case failure(Error)

     /// Returns `true` if the result is a success, `false` otherwise.
     public var isSuccess: Bool {
         switch self {
         case .success:
             return true
         case .failure:
             return false
         }
     }
 }
 
 
 */
