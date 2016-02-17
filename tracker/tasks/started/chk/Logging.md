# Title: Logging Mechanism
- Category: **Framework Stored Procedures and Functions**
- Status: **In Progress**

## Comments
- All transactions are logged to a **DEBUG_LOG** table should it be present in the database
- The following code objects are involved with the various logging aspects:
 - *Prettify*
 - *SayNull*
 - *StrCln*
 - *spActionOnEnd*
 - *spActionOnException*
 - *spActionOnStart*
 - *spDebugLogger*
 - *spErrorHandler*
 - *spSimpleLog*
- Sample query:
 - *select*  ** from DEBUG_LOG order by DATE_REGISTERED desc*;
