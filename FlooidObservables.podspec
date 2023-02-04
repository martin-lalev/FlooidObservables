Pod::Spec.new do |s|

s.name         = "FlooidObservables"
s.version      = "0.0.13"
s.summary      = "Lightweight FRP framework"
s.description  = "Lightweight FRP framework"
s.homepage     = "http://github.com/martin-lalev/FlooidObservables"
s.license      = "MIT"
s.author       = "Martin Lalev"
s.platform     = :ios, "11.0"
s.source       = { :git => "https://github.com/martin-lalev/FlooidObservables.git", :tag => s.version }
s.source_files  = "FlooidObservables", "FlooidObservables/**/*.{swift}"
s.swift_version = '5.0'

end
