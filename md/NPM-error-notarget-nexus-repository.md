# Something small: npm ERR! notarget

## npm ERR! notarget when using a Nexus repository that takes packages from npm

I had a build that was previously fine, but after changing a line that was unrelated to anything, the build failed with the following message:

```
[12:04:38][Step 2/7] Step 1/1: NPM Install (Command Line) (14s)
[12:04:38][Step 1/1] Starting: [REDACTED]
[12:04:38][Step 1/1] in directory: [REDACTED]
[12:04:42][Step 1/1] npm WARN deprecated istanbul@0.4.5: This module is no longer maintained, try this instead:
[12:04:42][Step 1/1] npm WARN deprecated   npm i nyc
[12:04:42][Step 1/1] npm WARN deprecated Visit https://istanbul.js.org/integrations for other alternatives.
[12:04:45][Step 1/1] npm WARN deprecated circular-json@0.5.9: CircularJSON is in maintenance only, flatted is its successor.
[12:04:50][Step 1/1] npm WARN deprecated circular-json@0.3.3: CircularJSON is in maintenance only, flatted is its successor.
[12:04:52][Step 1/1] npm ERR! code ETARGET
[12:04:52][Step 1/1] npm ERR! notarget No matching version found for @angular-devkit/build-webpack@0.800.4
[12:04:52][Step 1/1] npm ERR! notarget In most cases you or one of your dependencies are requesting
[12:04:52][Step 1/1] npm ERR! notarget a package version that doesn't exist.
[12:04:52][Step 1/1] npm ERR! notarget 
[12:04:52][Step 1/1] npm ERR! notarget It was specified as a dependency of '@angular-devkit/build-angular'
[12:04:52][Step 1/1] npm ERR! notarget 
[12:04:52][Step 1/1] 
[12:04:52][Step 1/1] npm ERR! A complete log of this run can be found in:
[12:04:52][Step 1/1] npm ERR!     [REDACTED]
[12:04:52][Step 1/1] Process exited with code 1
[12:04:53][Step 1/1] Process exited with code 1
[12:04:52][Step 1/1] Step NPM Install (Command Line) failed
```

Note the line about "No matching version found"! 

In my package.json file, I had 

```
    "@angular-devkit/build-angular": "~0.800.0",
```
Looking over on Github, I found that Angular's devkit/build-angular had just been updated an hour ago. 

The Nexus repository that my project used takes a day or so to update. So because I had selected the latest patch version of that angular-devkit package, npm knew that a new one had come out but the project could not find it on Nexus. 

I refreshed myself on the version numbering format. 

```
Number order:

major version, minor version, patch version
```

```
equals  "=0.800.0"  exact version

caret   "^0.800.0"  minor version

tilde   "~0.800.0"  patch version
```

The equals will get me exactly version 0.800.0. 

The caret gets me 0.801.0 if it exists, but wouldn't update for a new 1.000.0.

The tilde gets me 0.800.1 if it exists, but wouldn't update for 0.801.0.

Good to keep in mind! 
