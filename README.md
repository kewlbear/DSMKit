# DSMKit

Swift library for Synology DSM APIs

[![CI Status](http://img.shields.io/travis/kewlbear/DSMKit.svg?style=flat)](https://travis-ci.org/kewlbear/DSMKit)
[![Version](https://img.shields.io/cocoapods/v/DSMKit.svg?style=flat)](http://cocoapods.org/pods/DSMKit)
[![License](https://img.shields.io/cocoapods/l/DSMKit.svg?style=flat)](http://cocoapods.org/pods/DSMKit)
[![Platform](https://img.shields.io/cocoapods/p/DSMKit.svg?style=flat)](http://cocoapods.org/pods/DSMKit)

## Usage

```
import DSMKit

let dsm = DSM(host: "<IP address or hostname>")

dsm.get(API.Auth.login(account: "<account>", password: "<password>")) { sessionId, error in
    // ...
}

...

dsm.get(FileStation.List.list(path: "<path>") { data, error in
    // data?.files[0].name
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift 4

## Installation

DSMKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DSMKit'
```

## TODO

- support more APIs
- divide pod into sub specs
- ...

## Author

Changbeom Ahn, kewlbear@gmail.com

## Inspirations

http://kwent.github.io/syno

## License

DSMKit is available under the MIT license. See the LICENSE file for more info.
