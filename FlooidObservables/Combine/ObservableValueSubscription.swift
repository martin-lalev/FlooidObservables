//
//  ObservableValueSubscription.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Combine

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
class ObservableValueSubscription<Value, S: Combine.Subscriber>: Combine.Subscription where S.Input == Value {
    let subscriber: S
    var token: NSObjectProtocol?

    init(with subscriber: S) {
        self.subscriber = subscriber
    }
    deinit {
        self.token = nil
    }
    
    func request(_ demand: Subscribers.Demand) {}
    func cancel() { self.token = nil }

    func attach<O: ObservableValue>(to bindable: O) where O.Value == Value {
        self.token = bindable.add { [weak self] value in
            _ = self?.subscriber.receive(value)
        }
        _ = self.subscriber.receive(bindable.value)
        self.subscriber.receive(subscription: self)
    }
}

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
extension ObservableValue where Self: Publisher, Value == Output {
    public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        ObservableValueSubscription(with: subscriber).attach(to: self)
    }
}

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
extension Bindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
extension MutableBindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}
