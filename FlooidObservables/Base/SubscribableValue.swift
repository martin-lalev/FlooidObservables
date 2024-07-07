//
//  ValuePublisher.swift
//  
//
//  Created by Martin Lalev on 06/07/2024.
//

import Foundation

public protocol SubscribableValue<Value> {
    associatedtype Value
    func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol
}
