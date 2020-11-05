FilesUtil
=========

This repository contains generic code relating to files in iOS and OS X file systems, including code to monitor directories in iOS and OS X apps and issue notifications as files are added/removed/renamed, as well as simple wrappers to common NSFileSystem calls to find and create files in an iOS app. 

It also now includes generic code to read and parse both JSON and .plist files into NSArray and NSDictionary objects, as well as code to write such objects back to JSON files. 

NOTE: This revision includes breaking changes to methods '+arrayFromBundle_plist:' and '+dictionaryFromBundle_plist:' by adding an 'outError' parameter.

This code is used in several standalone apps included in my GitHub public repositories, on the assumption all the repositories have been copied/cloned to the same parent folder. To simplify this, my GitHub repository 'unix-scripts' includes a script named 'cloneall' to automate the download of all my public repositories to a single Mac folder; the script contains detailed instructions on its use. 

This code is distributed under the terms of the MIT license. See file "LICENSE" in each repository for details.

Copyright (c) 2014-2020 Steve Caine. <br>
@SteveCaine on github.com

Revison History:<br>
2014-09-20 - created<br>
2015-06-23 - code to list/sort/add/merge files in/out of directories<br>
2015-06-28 - code to count/clear files from directories based on type<br>
2017-04-29 - code to read/write JSON and .plist files in/out of NS arrays/dictionaries<br>
2017-12-30 - improve validation of writing objects to JSON<br>
2020-11-01 - merged changes from 'private' version of repo<br>
