//
//  UserDefaultsBindableProvider.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 1.11.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class UserDefaultsBindableProvider {
    
    private let bindableSink = BindableSink()
    private let userDefaults: UserDefaults
    
    public init(with userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func bindable<Value: Hashable>(for key: String, defaultValue: Value?) -> MutableBindable<Value?> {
        let bindable = MutableBindable(with: self.userDefaults.object(forKey: key) as? Value ?? defaultValue)
        bindable.bind(into: self.bindableSink) { [weak self] newValue in
            if let newValue = newValue {
                self?.userDefaults.set(newValue, forKey: key)
            } else {
                self?.userDefaults.removeObject(forKey: key)
            }
        }
        return bindable
    }

}
