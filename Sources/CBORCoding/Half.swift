import Foundation

#if canImport(Half) && swift(<5.3)
import Half

typealias Float16 = Half
#endif
