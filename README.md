# Run-Java-Script-in-Delphi

<img align="left" src="Images\spider-monkey-fb.jpg"/>

This example illustrates how to incorporate JavaScript in Delphi, call Delphi objects in a script, exchange data between the main app and a script, and use Node.js modules.

The following article summarizes an experience using SpiderMonkey JavaScript to run scripts in Delphi: [Getting started with SpiderMonkey to run JavaScript in Delphi](https://www.clevercomponents.com/articles/article053/)

## How to compile

1. Download the latest stable release of the [mORMot integration library](https://github.com/synopse/mORMot)
2. Download the SpiderMonkey precompiled and prepared for mORMot binaries: [SpiderMonkey52 DLLs](https://github.com/synopse/mORMot/blob/master/SyNode/README.md)
3. Clone the [FastMM4](https://github.com/pleriche/FastMM4) repository.
4. Add links in Delphi Library Paths to the following directories: "...mORMot\", "...mORMot\SyNode\", "...\mORMot\SQLite3\", and "...FastMM4\".
5. Put downloaded SpiderMonkey DLLs near the app executable or add a link to these DLLs to the PATHS environment variable.
