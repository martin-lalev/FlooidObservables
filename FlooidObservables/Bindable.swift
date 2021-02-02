//
//  Bindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 31.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import Combine

public protocol ObservableValue {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: Any, selector: Selector)
    func remove(_ observer: Any)
}

@propertyWrapper
@dynamicMemberLookup
public class Bindable<Value>: ObservableValue {
    
    var _value: () -> Value
    var _add: (Any, Selector) -> Void
    var _remove: (Any) -> Void
    
    init<Base: ObservableValue>(_ base: Base) where Base.Value == Value {
        self._value = { base.value }
        self._add = base.add
        self._remove = base.remove
    }
    
    public var wrappedValue: Value { self.value }
    
    public var projectedValue: Bindable<Value> { self }
    
    public func add(_ target: Any, selector: Selector) {
        self._add(target, selector)
    }
    public func remove(_ target: Any) {
        self._remove(target)
    }
    
    public var value: Value {
        return self._value()
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Value,T>) -> Bindable<T> { self.map { $0[keyPath: keyPath] }.asAny() }
}

public extension ObservableValue {
    func asAny() -> Bindable<Value> { return Bindable(self) }
}

public typealias BindableList<T> = Bindable<[T]>

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
extension Bindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        Subscription(with: subscriber).attach(to: self)
    }

    private class Subscription<Value, S: Combine.Subscriber>: Combine.Subscription where S.Input == Value {
        let subscriber: S
        let bindableSink = BindableSink()

        init(with subscriber: S) {
            self.subscriber = subscriber
        }
        deinit {
            self.bindableSink.clean()
        }
        
        func request(_ demand: Subscribers.Demand) {}
        func cancel() { self.bindableSink.clean() }

        func attach(to bindable: Bindable<Value>) {
            bindable.bind(into: self.bindableSink) { [weak self] value in
                _ = self?.subscriber.receive(value)
            }
            _ = self.subscriber.receive(bindable.value)
            self.subscriber.receive(subscription: self)
        }
    }
}

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
public class PublishedBindable<Value, O: ObservableObject>: ObservableValue {
    let observableObject: O
    let keyPath: KeyPath<O, Value>
    private let name: Notification.Name = .init("published_bindable")
    private var cancellable: Cancellable?

    init(for observableObject: O, keyPath: KeyPath<O, Value>) {
        self.observableObject = observableObject
        self.keyPath = keyPath

        self.cancellable = self.observableObject.objectWillChange.sink { value in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.name, object: self, userInfo: nil)
            }
        }
    }
    deinit {
        self.cancellable?.cancel()
        self.cancellable = nil
    }
    
    public var value: Value {
        return self.observableObject[keyPath: self.keyPath]
    }
    public func add(_ target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target, selector: selector, name: self.name, object: self)
    }
    public func remove(_ target: Any) {
        NotificationCenter.default.removeObserver(target, name: self.name, object: self)
    }
}

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
public extension ObservableObject {
    func bindable<Value>(for keyPath: KeyPath<Self, Value>) -> PublishedBindable<Value, Self> {
        return .init(for: self, keyPath: keyPath)
    }
}
