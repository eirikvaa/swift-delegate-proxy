/// A request is sent to a proxy that corresponds to an event of the particular delegate you wish
/// to communicate with. For instance, requesting a single location from CoreLocation would require
/// a SingleLocationRequest and a SingleLocationEvent.
public protocol Request {
    associatedtype Value
    associatedtype RequestError: Error

    var events: [Event.Type] { get }
    func linkContinuation(_ continuation: CheckedContinuation<Value, RequestError>)
    func response(_ event: any Event)
}

public extension Request {
    func respondsToEvent(_ eventType: Event.Type) -> Bool {
        events.contains(where: { $0 == eventType })
    }
}

/// An event that corresponds to a delegate method you wish to obtain results from.
public protocol Event {}

/// The proxy mediates between your async data provider and the delegate you wish to
/// wrap async access over.
public class Proxy {
    public var requests: [any Request]

    public init(requests: [any Request] = []) {
        self.requests = requests
    }

    public func addRequest(_ request: any Request) {
        requests.append(request)
    }

    public func respond(_ event: some Event) {
        guard let requestIndex = requests.firstIndex(where: { $0.respondsToEvent(type(of: event)) }) else {
            return
        }

        let request = requests[requestIndex]

        request.response(event)
        requests.remove(at: requestIndex)
    }
}
