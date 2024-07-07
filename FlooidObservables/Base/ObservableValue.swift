//
//  ObservableValue.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Foundation

public protocol ObservableValue<Value>: SubscribableValue {
    var value: Value { get }
}
