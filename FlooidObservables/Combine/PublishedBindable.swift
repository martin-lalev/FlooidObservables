//
//  PublishedBindable.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Combine

public class PublishedBindable<Value, O: ObservableObject>: ObservableValue {
    weak var observableObject: O?
    let keyPath: KeyPath<O, Value>
    private let name: Notification.Name = .init("published_bindable")
    private var cancellable: Cancellable?

    init(for observableObject: O, keyPath: KeyPath<O, Value>) {
        self.observableObject = observableObject
        self.keyPath = keyPath

        self.cancellable = observableObject.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.observableObject != nil else { return }
                NotificationCenter.default.post(name: self.name, object: self, userInfo: nil)
            }
        }
    }
    deinit {
        self.cancellable?.cancel()
        self.cancellable = nil
    }
    
    public var value: Value {
        return self.observableObject![keyPath: self.keyPath]
    }
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self.name, object: self, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            observer(self.value)
        }
    }
}

public extension ObservableObject {
    func bindable<Value>(for keyPath: KeyPath<Self, Value>) -> PublishedBindable<Value, Self> {
        return .init(for: self, keyPath: keyPath)
    }
}
