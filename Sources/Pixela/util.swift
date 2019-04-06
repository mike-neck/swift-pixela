import Foundation

extension JSONEncoder {

    func encode<T>(object value: T?) throws -> Data? where T: Encodable {
        do {
            return try encodeJson(value).get()
        }
    }

    func encodeJson<T: Encodable>(_ value: T?) -> Result<Data?, Error> {
        guard let object = value else {
            return .success(nil)
        }
        return Result(catching: {
            return try self.encode(object)
        })
    }
}

extension JSONDecoder {

    func decode<T: Decodable>(json: Data, as type: T.Type) -> Result<T, Error> {
        do {
            let object: T = try decode(type, from: json)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }
}

extension Optional {

    func asResult(_ error: @autoclosure @escaping () -> Error) -> Result<Wrapped, Error> {
        switch self {
        case .none: return .failure(error())
        case .some(let value): return .success(value)
        }
    }
}

protocol HttpStatus {
    func statusCode(onError: @autoclosure @escaping () -> Error) -> Result<Int, Error>
}

extension URLResponse: HttpStatus {

    func asHttpUrlResponse(_ error: @autoclosure @escaping () -> Error) -> Result<HTTPURLResponse, Error> {
        guard let response = self as? HTTPURLResponse else {
            return .failure(error())
        }
        return .success(response)
    }

    func statusCode(onError: @autoclosure @escaping () -> Error) -> Result<Int, Error> {
        return self.asHttpUrlResponse(onError()).map { $0.statusCode }
    }
}

extension Result {

    func doOn(success: (Success) -> Void, failure: (Failure) -> Void) {
        switch self {
        case .success(let value): success(value)
        case .failure(let error): failure(error)
        }
    }
}

struct DataWrapper {
    let data: Data?

    init(of data: Data?) {
        self.data = data
    }

    func unwrap() -> Result<Data, Error> {
        if let body = data {
            return .success(body)
        }
        return .failure(PixelaApiError.invalidResponse(message: "error - response body is not available"))
    }
}

struct Maybe<T> {

    let raw: T?

    init(_ raw: T?) {
        self.raw = raw
    }

    func get(or error: @autoclosure @escaping () -> Error) -> Result<T, Error> {
        if let v = raw {
            return .success(v)
        }
        return .failure(error())
    }
}
