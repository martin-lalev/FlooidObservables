//
//  File.swift
//  
//
//  Created by Martin Lalev on 12/03/2022.
//

import Foundation

public class PublishedModelObservable<O: ObservableModelType>: ObservableValue {
    
    private let dispatcher: MutableBindable<O>
    private var cancellable: NSObjectProtocol?
    
    init(for observableObject: O) {
        self.dispatcher = MutableBindable(with: observableObject)
        
        self.cancellable = observableObject.objectWillUpdate.add { [weak self] _ in
            guard let self = self else { return }
            self.dispatcher.update(to: observableObject)
        }
    }
    deinit {
        self.cancellable = nil
    }
    
    public var value: O {
        return self.dispatcher.value
    }
    public func add(_ observer: @escaping (O) -> Void) -> NSObjectProtocol {
        dispatcher.add(observer)
    }
}

public extension ObservableModelType {
    func bindable() -> PublishedModelObservable<Self> {
        return .init(for: self)
    }

    func bindable<Value>(for keyPath: KeyPath<Self, Value>) -> MappedBindable<PublishedModelObservable<Self>,Value> {
        return PublishedModelObservable(for: self).map { $0[keyPath: keyPath] }
    }
}
