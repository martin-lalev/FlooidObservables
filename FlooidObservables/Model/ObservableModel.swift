//
//  File.swift
//  
//
//  Created by Martin Lalev on 19/02/2022.
//

import Foundation

public protocol ObservableModelType: AnyObject {
    var objectWillUpdateStorage: ObservableModelDispatcher { get }
    var objectWillUpdate: MutableBindable<Void> { get }
}

open class ViewModelBase {
    public let objectWillUpdateStorage = ObservableModelDispatcher()
    public required init() { }
}

public typealias ObservableModel = ObservableModelType & ViewModelBase

public typealias IdentifiableObservableModel = ObservableModelType & ViewModelBase & Identifiable
