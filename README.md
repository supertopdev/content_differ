# Text task for AgileEngine
Compare content of 2 files, git like style

### Usage
```sh
bundle exec diff.rb file1.txt file2.txt
"1 * Some | Another"
"2 - Simple"
"3 Text"
"4 File"
"5 + With"
"6 + Additional"
"7 + Lines"
```


### TODO
* Logger
* handle mutiply files to reverse merge changes
* catch IO exceptions
* patch Diff to split unchanged lines