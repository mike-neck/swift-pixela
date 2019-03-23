import Foundation

extension JSONEncoder {

    func encode<T>(object value: T) throws -> Data? where T : Encodable {
        if let obj = value {
            do {
                return try self.encode(obj)
            } catch {
                throw error
            }
        } else {
            return nil
        }
    }
}
