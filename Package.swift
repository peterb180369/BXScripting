// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BXScripting",
    defaultLocalization: "en",
    
    platforms:
    [
 		.macOS("10.15.2"),
   ],
    
	// Products define the executables and libraries a package produces, and make them visible to other packages
        
    products:
    [
        .library(name:"BXScripting", targets:["BXScripting"]),
    ],
    
	// Dependencies declare other packages that this package depends on
	
    dependencies:
    [
//        .package(url: "git@github.com:boinx/BXSwiftUtils.git", .branch("master")),
		.package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
    ],
    
	// Targets are the basic building blocks of a package. A target can define a module or a test suite.
	// Targets can depend on other targets in this package, and on products in packages this package depends on.

    targets:
    [
        .target(name:"BXScripting", dependencies:[.product(name:"Lottie", package:"lottie-spm")]),
//		.testTarget( name:"BXScriptingTests", dependencies:["BXScripting"]),
    ]
)
