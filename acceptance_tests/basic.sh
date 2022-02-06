#!/bin/bash

setUp() {
  rm test*.yml || true
}

testBasicEvalRoundTrip() {
  ./yq -n ".a = 123" > test.yml
  X=$(./yq '.a' test.yml)
  assertEquals 123 "$X"
}

testBasicPipeWithDot() {
  ./yq -n ".a = 123" > test.yml
  X=$(cat test.yml | ./yq '.')
  assertEquals "a: 123" "$X"
}

testBasicAllFiles() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(./yq test.yml test2.yml)
  Y=$(./yq e '.' test.yml test2.yml)
  assertEquals "$Y" "$X"
}

testBasicEvalAllAllFiles() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(./yq ea test.yml test2.yml)
  Y=$(./yq e '.' test.yml test2.yml)
  assertEquals "$Y" "$X"
}


testBasicStdInWithFiles() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(cat test.yml | ./yq - test2.yml)
  Y=$(./yq e '.' test.yml test2.yml)
  assertEquals "$Y" "$X"
}

testBasicEvalAllStdInWithFiles() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(cat test.yml | ./yq ea - test2.yml)
  Y=$(./yq e '.' test.yml test2.yml)
  assertEquals "$Y" "$X"
}

testBasicStdInWithFilesReverse() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(cat test.yml | ./yq test2.yml -)
  Y=$(./yq e '.' test2.yml test.yml)
  assertEquals "$Y" "$X"
}

testBasicEvalAllStdInWithFilesReverse() {
  ./yq -n ".a = 123" > test.yml
  ./yq -n ".a = 124" > test2.yml
  X=$(cat test.yml | ./yq ea test2.yml -)
  Y=$(./yq e '.' test2.yml test.yml)
  assertEquals "$Y" "$X"
}

testBasicEvalRoundTripNoEval() {
  ./yq -n ".a = 123" > test.yml
  X=$(./yq '.a' test.yml)
  assertEquals 123 "$X"
}

testBasicStdInWithOneArg() {
  ./yq e -n ".a = 123" > test.yml
  X=$(cat test.yml | ./yq e ".a")
  assertEquals 123 "$X"

  X=$(cat test.yml | ./yq ea ".a")
  assertEquals 123 "$X"

  X=$(cat test.yml | ./yq ".a")
  assertEquals 123 "$X"
}

testBasicUpdateInPlaceSequence() {
  cat >test.yml <<EOL
a: 0
EOL
  ./yq e -i ".a = 10" test.yml
  X=$(./yq e '.a' test.yml)
  assertEquals "10" "$X"
}

testBasicUpdateInPlaceSequenceNoEval() {
  cat >test.yml <<EOL
a: 0
EOL
  ./yq -i ".a = 10" test.yml
  X=$(./yq '.a' test.yml)
  assertEquals "10" "$X"
}

testBasicUpdateInPlaceSequenceEvalAll() {
  cat >test.yml <<EOL
a: 0
EOL
  ./yq ea -i ".a = 10" test.yml
  X=$(./yq e '.a' test.yml)
  assertEquals "10" "$X"
}

testBasicNoExitStatus() {
  echo "a: cat" > test.yml
  X=$(./yq e '.z' test.yml)
  assertEquals "null" "$X"
}

testBasicExitStatus() {
  echo "a: cat" > test.yml
  X=$(./yq e -e '.z' test.yml 2&>/dev/null)
  assertEquals 1 "$?"
}

testBasicExitStatusNoEval() {
  echo "a: cat" > test.yml
  X=$(./yq -e '.z' test.yml 2&>/dev/null)
  assertEquals 1 "$?"
}

testBasicExtractFieldWithSeperator() {
    cat >test.yml <<EOL
---
name: chart-name
version: 1.2.3
EOL
  X=$(./yq e '.name' test.yml)
  assertEquals "chart-name" "$X"
}

testBasicExtractMultipleFieldWithSeperator() {
    cat >test.yml <<EOL
---
name: chart-name
version: 1.2.3
---
name: thing
version: 1.2.3
EOL

read -r -d '' expected << EOM
chart-name
---
thing
EOM
  X=$(./yq e '.name' test.yml)
  assertEquals "$expected" "$X"
}

source ./scripts/shunit2