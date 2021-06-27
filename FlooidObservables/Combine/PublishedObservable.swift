//
//  PublishedObservable.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Combine

@available(iOSApplicationExtension 13.0, *)
public class PublishedObservable<O: ObservableObject>: ObservableValue {
    weak var observableObject: O?
    
    private let name: Notification.Name = .init("published_bindable")
    private var cancellable: Cancellable?

    init(for observableObject: O) {
        self.observableObject = observableObject
        

        self.cancellable = observableObject.objectWillChange.sink { [weak self] value in
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
    
    public var value: O {
        return self.observableObject!
    }
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self.name, object: self, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            observer(self.observableObject!)
        }
    }
}

@available(iOSApplicationExtension 13.0, *)
public extension ObservableObject {
    func bindable() -> PublishedObservable<Self> {
        return .init(for: self)
    }
}
