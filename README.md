## Image fetcher

### Task description
Given a plaintext file containing URLs, one per line, e.g.:

```
http://mywebserver.com/images/271947.jpg
http://mywebserver.com/images/24174.jpg
http://somewebsrv.com/img/992147.jpg
```

Write a command line script that takes this plaintext file as an
argument and downloads all images, storing them on the local hard
disk.

### Testing the solution

There's the `bin/get_images` command which:
* accepts an argument for the plain text file path 
* displays the results of execution

#### Supported image formats
* `jpg`
* `jpeg`
* `png`
* `gif`

#### Errors during the execution
Currently, the flow handles 2 types of errors during execution:
1. Invalid image URL.
2. Something went wrong during processing of an image from an URL (the simplest e.g.: **no internet connection**). 

#### Example files

`fixtures` folder contains simple examples for manual testing.

#### Results based on `fixtures`

```
➜  get_safe git:(master) ✗ bin/get_images fixtures/success_manual_tests.txt
All images have been saved

➜  get_safe git:(master) ✗ bin/get_images fixtures/failed_manual_tests.txt
===== Urls failed during url validation =====
 - https://i.ytimg.com/vi/AIQLBiGUCQ4/pew
 - https://i.pinimg.com/originals/21/97/2a/21972a5983e176b086470645bd8f7700.pg
 - data:image/jeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD

===== Urls failed during processing =====
 - https://thumbs.gfycat.com/GeneralGroundedFish-size_restricted.gif
```
