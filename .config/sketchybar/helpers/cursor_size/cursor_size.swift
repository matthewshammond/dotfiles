// cursor_size: get/set macOS pointer size live (1.0-4.0) via private CGS API,
// and persist to com.apple.universalaccess so System Settings agrees.
import Foundation
import CoreGraphics

typealias CGSConn = Int32
@_silgen_name("CGSMainConnectionID") func CGSMainConnectionID() -> CGSConn
@_silgen_name("CGSSetCursorScale") func CGSSetCursorScale(_ c: CGSConn, _ s: Float) -> Int32
@_silgen_name("CGSGetCursorScale") func CGSGetCursorScale(_ c: CGSConn, _ s: UnsafeMutablePointer<Float>) -> Int32

let args = CommandLine.arguments
let cid = CGSMainConnectionID()
if args.count < 2 {
    var s: Float = 0
    _ = CGSGetCursorScale(cid, &s)
    print(String(format: "%.4f", s))
    exit(0)
}
guard let v = Float(args[1]), v >= 1.0, v <= 4.0 else {
    FileHandle.standardError.write("usage: cursor_size [1.0-4.0]\n".data(using: .utf8)!); exit(2)
}
let r = CGSSetCursorScale(cid, v)
let d = UserDefaults(suiteName: "com.apple.universalaccess")
d?.set(Double(v), forKey: "mouseDriverCursorSize")
d?.synchronize()
exit(r == 0 ? 0 : 1)
