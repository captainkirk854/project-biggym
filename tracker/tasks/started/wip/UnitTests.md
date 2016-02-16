# Title:
- Category: **Testing: Unit Tests**
- Status: * **In progress** *

## Comments
- Unit Tests make use of the **mytap-0.02** framework
 - written by David Wheeler
 - Available on: https://github.com/theory/mytap/blob/master/mytap.sql
- Unit Test files are suffixed with **.ut** and are stored in the same directory as source
- Unit Tests exist for the main API stored procedures
- Unit Tests exist for some of the lower level functions and stored procedures
- Tests can be executed using test-runner **tools** in two ways:
 - single - using **runMYTAPUnitTest.sh**
 - all - using **runMYTAPUnitTests.sh**

## Notes
 - *The test-runner tools will require a little bit of configuration and $PATHing in line with the local environment*
 - There are dependencies within the test-runner tools on contents from  
https://github.com/captainkirk854/codeMusings-KornShell/tree/master/tools
