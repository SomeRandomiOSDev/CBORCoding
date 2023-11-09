import Foundation

#if canImport(Half) && swift(<5.3) || (
  os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)
import Half

typealias Float16 = Half
#endif
