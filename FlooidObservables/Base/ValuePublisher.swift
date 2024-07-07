//
//  Dispatcher.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 08/08/2021.
//

import Foundation

fileprivate final class WeakRef<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}

public class PublisherSubscription<Value>: NSObject {
    let action: (Value) -> Void
    
    public init(_ action: @escaping (Value) -> Void) {
        self.action = action
        super.init()
    }
}

public class ValuePublisher<Value>: SubscribableValue {
    private var subscriptions: [WeakRef<PublisherSubscription<Value>>] = []
    
    public init() {}
    
    public func post(_ value: Value) {
        for observer in subscriptions {
            observer.value?.action(value)
        }
    }
    
    public func add(subscription: PublisherSubscription<Value>) -> NSObjectProtocol {
        self.subscriptions.append(.init(subscription))
        return subscription
    }
    
    public func add(_ action: @escaping (Value) -> Void) -> NSObjectProtocol {
        return self.add(subscription: PublisherSubscription(action))
    }
}
