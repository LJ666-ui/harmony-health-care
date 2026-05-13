@echo off
set MAVEN_OPTS=--add-opens=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
cd /d e:\harmony-health-care
mvn clean compile
echo Exit Code: %ERRORLEVEL%
pause
