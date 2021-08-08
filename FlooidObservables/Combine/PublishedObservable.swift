//
//  PublishedObservable.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Combine

public class PublishedObservable<O: ObservableObject>: ObservableValue {
    
    private let dispatcher: MutableBindable<O>
    private var cancellable: Cancellable?

    init(for observableObject: O) {
        self.dispatcher = MutableBindable(with: observableObject)
        
        self.cancellable = observableObject.objectWillChange.sink { [weak self] value in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dispatcher.update(to: observableObject)
            }
        }
    }
    deinit {
        self.cancellable?.cancel()
        self.cancellable = nil
    }
    
    public var value: O {
        return self.dispatcher.value
    }
    public func add(_ observer: @escaping (O) -> Void) -> NSObjectProtocol {
        dispatcher.add(observer)
    }
}

public extension ObservableObject {
    func bindable() -> PublishedObservable<Self> {
        return .init(for: self)
    }

    func bindable<Value>(for keyPath: KeyPath<Self, Value>) -> MappedBindable<PublishedObservable<Self>,Value> {
        return PublishedObservable(for: self).map { $0[keyPath: keyPath] }
    }
}
