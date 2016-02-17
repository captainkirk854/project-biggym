# User Information

## Implementation Overview
### Back End

- **PERSON** (table):
 - Supporting stored procedures for creation, modification and deletion.
 - user personal details
   - Forename
   - Surname
   - DOB


- **PROFILE** (table):
 - Supporting stored procedures for creation, modification and deletion.
 - Training Profile Name (one user can have multiple profiles)
 - profile name and links to PERSON (1<-n)
