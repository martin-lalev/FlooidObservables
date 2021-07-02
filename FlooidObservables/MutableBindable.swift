//
//  MutableBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

@propertyWrapper
@dynamicMemberLookup
public class MutableBindable<Value> {
    
    private var storedValue: Value
    private let dispatcher: Dispatcher = ClosureDispatcher()
    
    public init(with value: Value) {
        self.storedValue = value
    }
    public init(wrappedValue value: Value) {
        self.storedValue = value
    }

    public var wrappedValue: Value {
        get { self.value }
        set { self.update(to: newValue) }
    }
    
    public var projectedValue: MutableBindable<Value> { self }

    public func update(to value: Value) {
        self.storedValue = value
        dispatcher.post()
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        return self.storedValue[keyPath: keyPath]
    }
    
    public func update(_ updater: (inout Value) -> Void) {
        var value = self.value
        updater(&value)
        self.update(to: value)
    }
}

extension MutableBindable: ObservableValue {

    public var value: Value {
        return self.storedValue
    }
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        dispatcher.add { [weak self] in
            guard let self = self else { return }
            observer(self.value)
        }
    }
}


protocol Dispatcher {
    func post()
    func add(_ action: @escaping () -> Void) -> NSObjectProtocol
}
class NotificationDispatcher: Dispatcher {
    private let name: Notification.Name
    init(_ name: String) { self.name = .init(name) }
    func post() {
        NotificationCenter.default.post(name: self.name, object: self, userInfo: nil)
    }
    func add(_ action: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self.name, object: self, queue: .main) { _ in
            action()
        }
    }
}
class ClosureDispatcher: Dispatcher {
    class Weakened {
        weak var observer: Observer?
        init(_ observer: Observer) {
            self.observer = observer
        }
    }
    class Observer: NSObject {
        let action: () -> Void
        init(_ action: @escaping () -> Void) {
            self.action = action
            super.init()
        }
    }
    var observers: [Weakened] = []
    
    deinit {
        self.observers.removeAll()
    }
    
    func post() {
        for observer in observers {
            observer.observer?.action()
        }
    }
    
    func add(_ action: @escaping () -> Void) -> NSObjectProtocol {
        let observer = Observer(action)
        self.observers.append(.init(observer))
        self.observers.removeAll { $0.observer == nil }
        return observer
    }
}
