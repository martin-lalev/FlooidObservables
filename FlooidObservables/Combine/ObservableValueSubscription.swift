//
//  ObservableValueSubscription.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Foundation
import Combine

class ObservableValueSubscription<Value, S: Combine.Subscriber>: Combine.Subscription where S.Input == Value {
    
    class Subscriber<O: ObservableValue> {
        
        private var bindable: O
        private var observerToken: NSObjectProtocol?

        fileprivate init(to bindable: O, with action: @escaping (O.Value) -> Void) {
            self.bindable = bindable
            self.observerToken = bindable.add(action)
        }
        deinit {
            self.observerToken = nil
        }
    }

    let subscriber: S
    var disposings: [AnyObject] = []
    func clean() { self.disposings.removeAll() }

    init(with subscriber: S) {
        self.subscriber = subscriber
    }
    deinit { self.clean() }

    func request(_ demand: Subscribers.Demand) {}
    func cancel() { self.clean() }

    func attach<O: ObservableValue>(to bindable: O) where O.Value == Value {
        let subscriber = Subscriber(to: bindable) { [weak self] value in
            _ = self?.subscriber.receive(value)
        }
        self.disposings.append(subscriber)

        _ = self.subscriber.receive(bindable.value)
        self.subscriber.receive(subscription: self)
    }
}

extension ObservableValue where Self: Publisher, Value == Output {
    public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        ObservableValueSubscription(with: subscriber).attach(to: self)
    }
}

extension Bindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

extension MutableBindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

extension MappedBindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

extension Combined2Bindables: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

extension Combined3Bindables: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}

extension CombinedArrayBindables: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
}
