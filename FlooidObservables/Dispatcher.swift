//
//  Dispatcher.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 08/08/2021.
//

import Foundation

protocol Dispatcher {
    func post()
    func add(_ action: @escaping () -> Void) -> NSObjectProtocol
}


// MARK: - NotificationDispatcher

class NotificationDispatcher: Dispatcher {
    private let name: Notification.Name
    init(_ name: String) { self.name = .init(name) }
    func post() {
        NotificationCenter.default.post(name: self.name, object: self, userInfo: nil)
    }
    func add(_ action: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self.name, object: self, queue: nil) { _ in
            action()
        }
    }
}


// MARK: - ClosureDispatcher

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
    init() {}
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
