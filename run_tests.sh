#!/bin/bash

# Run all tests
echo "Running all tests..."
xcodebuild test \
  -project rmProApp.xcodeproj \
  -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -quiet

# Run specific test class
echo "Running RentManagerAPIClientTests..."
xcodebuild test \
  -project rmProApp.xcodeproj \
  -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:rmProAppTests/RentManagerAPIClientTests \
  -quiet

# Run specific test method
echo "Running individual test..."
xcodebuild test \
  -project rmProApp.xcodeproj \
  -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:rmProAppTests/RentManagerAPIClientTests/testAPIClientInitialization \
  -quiet

# Run with detailed output
echo "Running with verbose output..."
xcodebuild test \
  -project rmProApp.xcodeproj \
  -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -enableCodeCoverage YES \
  | xcpretty --test --color

# Generate test report
echo "Generating test report..."
xcodebuild test \
  -project rmProApp.xcodeproj \
  -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -resultBundlePath TestResults.xcresult