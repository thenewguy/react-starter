@ECHO OFF

SETLOCAL

pushd vagrant-bin
set PATH=%CD%;%PATH%
popd

ECHO ON

@vagrant.exe %*