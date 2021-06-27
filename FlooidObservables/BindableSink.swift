//
//  BindableSink.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 16.11.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class BindableSink {
    var disposings: [AnyObject] = []
    public init() { }
    deinit { self.clean() }
    public func clean() { self.disposings.removeAll() }
}

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

public extension ObservableValue {
    
    func bind(into bindableSink: BindableSink, with action: @escaping (Value) -> Void) {
        bindableSink.disposings.append(Subscriber(to: self, with: action))
        action(self.value)
    }
}
