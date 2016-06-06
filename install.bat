@echo off
echo This script tries to automate the steps described at https://github.com/rchoetzlein/win_openvdb
echo Initialize project %1 with openvdb. Should work with vc2012, vc2013 and vc2015, x64 only (script requires minor changes to compile 32-bit).
mkdir "%1"
cd "%1"
set /p="Set up openvdb for %cd%. Hit Enter..."
set /p CONF="Please type "Debug" or "Release" to choose a configuration -> "
echo.
echo MANUAL ACTIONS REQUIRED: Go to following websites and download the correct package for you"
echo Q: Why should I use Linux instead?"
echo A: Linux users just type "sudo apt-get install openvdb". Versions, downloads, dependencies and configurations are handled automatically for you!
echo Now windows users, here we go...
rem Full package is over a gig... please choose manually
echo.
echo  https://sourceforge.net/projects/boost/files/boost-binaries/1.61.0/
echo  install manually to %1/codes/build/boost_1_61_0
echo.
echo If you don't have cmake, install it from https://cmake.org/download/ (newer than 2.8.12). You can proceed before manual installation has finished.
echo The script will prompt you a message before boost/cmake is needed.
set /p="Going to download other dependencies automatically. Please start boost/CMake download manually, hit Enter, grab a coffee..."
mkdir codes
cd codes
mkdir source
mkdir build
cd build
if not exist "glew-1.13.0-win32.zip" (
echo Downloading from https://sourceforge.net/projects/glew/files/glew/1.13.0/
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/glew/glew/1.13.0/glew-1.13.0-win32.zip', 'glew-1.13.0-win32.zip')"
)
if not exist "glew-1.13.0" (
echo Extracting to %1/codes/build/glew-1.13.0
powershell -Command "Expand-Archive %cd%\glew-1.13.0-win32.zip -dest %cd%"
)
echo GLEW Done.
echo.

echo NOTE: USING 64bit GLFW
if not exist "glfw-3.2.bin.WIN64.zip" (
echo Downloading from http://www.glfw.org/
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/glfw/glfw/releases/download/3.2/glfw-3.2.bin.WIN64.zip', 'glfw-3.2.bin.WIN64.zip')"
)
if not exist "glfw" (
echo Extracting to %1/codes/build/glfw
powershell -Command "Expand-Archive %cd%\glfw-3.2.bin.WIN64.zip -dest %cd%"
ren glfw-3.2.bin.WIN64 glfw
)
echo GLFW Done.
echo.

if not exist "tbb44_20160526oss_win.zip" (
echo Downloading from https://www.threadingbuildingblocks.org/
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.threadingbuildingblocks.org/sites/default/files/software_releases/windows/tbb44_20160526oss_win.zip', 'tbb44_20160526oss_win.zip')"
)
if not exist "tbb44" (
echo Extracting to %1/codes/build/tbb44
powershell -Command "Expand-Archive %cd%\tbb44_20160526oss_win.zip -dest %cd%"
ren tbb44_20160526oss tbb44
)
echo Intel Threading Building Blocks Done.
echo.

rem Feel free to set these as submodules in your project to benefit from updates
cd ..\source
echo Cloning repositories...
git clone https://github.com/dabulla/win_openvdb
echo Clone OpenVDB Done.
echo.
git clone https://github.com/dabulla/win_openexr.git
echo Clone OpenEXR/IlmBase Done.
echo.
git clone https://github.com/rchoetzlein/zlib.git
echo Clone zlib Done.
echo.
echo Proceed after you downloaded and installed boost manually to %1/codes/build/boost_1_61_0.
echo.
set /p MY_CMAKE="please type the path to your cmake.exe. E.g.: "C:\Program Files (x86)\CMake\bin\cmake.exe""
"%MY_CMAKE%" --help
set /p MY_CMAKE_GEN=Choose a generator from the above list. Note: Only supports x64, so add "Win64" (please copy paste name e.g. Visual Studio 12 Win64)
set /p MY_DEVENV=Specify full path of devenv.exe (with quotation marks). E.g. "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.com"
rem set PATH=%MY_DEVENV%;%PATH%
cd ..\build
mkdir zlib
cd zlib
echo Generate zlib - project for %MY_CMAKE_GEN%
"%MY_CMAKE%" -G "%MY_CMAKE_GEN%" ..\..\source\zlib
echo Compiling zlib
rem "%MY_DEVENV%" zlib.sln /build "%CONF%" /project ALL_BUILD only release works
"%MY_DEVENV%" zlib.sln /build "Release" /project ALL_BUILD

cd ..
mkdir IlmBase
cd IlmBase
echo Generate IlmBase - project for %MY_CMAKE_GEN%
"%MY_CMAKE%" -G "%MY_CMAKE_GEN%" ..\..\source\win_openexr\IlmBase
echo Compiling IlmBase
"%MY_DEVENV%" /build "%CONF%" IlmBase.sln /project ALL_BUILD

cd ..
mkdir OpenEXR
cd OpenEXR
echo Generate OpenEXR - project for %MY_CMAKE_GEN%
"%MY_CMAKE%" -G "%MY_CMAKE_GEN%" ..\..\source\win_openexr\OpenEXR
echo Compiling OpenEXR
"%MY_DEVENV%" /build "%CONF%" OpenEXR.sln /project ALL_BUILD

cd ..
mkdir OpenVDB
cd OpenVDB
echo Generate OpenVDB - project for %MY_CMAKE_GEN%
"%MY_CMAKE%" -G "%MY_CMAKE_GEN%" ..\..\source\win_openvdb\OpenVDB
echo Finally compiling OpenVDB
"%MY_DEVENV%" /build "%CONF%" OpenVDB.sln /project ALL_BUILD
echo Done!
cd ..\..\..\..