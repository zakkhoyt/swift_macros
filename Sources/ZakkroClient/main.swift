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

let invalidURL = #URL("https://invalid")


struct AsyncFunctions {
  @AddAsync
  func test(arg1: String, completion: (String) -> Void) {
  }
}
 
func testing() async {
    let result = await AsyncFunctions().test(arg1: "Blob")
}

Task {
    await testing()
}


let s = "myText"
logger.debug("\(s)")

//let l = #logify("myString")
//

@DebugLogger
class Foo {
}

let line = "\(#line) \(#filePath)"




func l() {
    print("l() called")
}

func test() {
    let i = 33
    #dlogify(i)
}

test()

print("hi from Zakkro")
