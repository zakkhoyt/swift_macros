import os
import Zakkro
import Foundation
let logger = os.Logger(subsystem: "com.vaporwarewolf", category: "ZakkroClient")

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")



//@DictionaryStorage
//enum Gender {
//    case male
//    case female
//}
//
//@DictionaryStorage
//struct Gender: DictionaryRepresentable {
//    let male: String
//    let female: String
//}
enum Slope {
    case beginnersParadise
    case practiceRun
    case livingRoom
    case olympicRun
    case blackBeauty
}

@SlopeSubset
enum EasySlope {
    case beginnersParadise
    case practiceRun
}


print("hi from Zakkro")
