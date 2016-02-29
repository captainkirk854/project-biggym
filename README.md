# Project-BigGym
Attempt at a personalised gym tracking system

## Configuration
Backend database: MYSQL

## Backend
### Installation

#### Install MYSQL
- Current working version: **Ver 14.14 Distrib 5.6.28, for debian-linux-gnu (x86_64)**

#### Unit Test Framework
- As root, install the **tap** schema using https://github.com/theory/mytap/blob/master/mytap.sql
- e.g. **mysql -u root -p < mytap.sql**

#### Local User Setup
- Rather than always having to always authenticate to MYSQL as root, we will be logging in as *BigJim*
- Use the ddl in **../backend/BIGGYM/cfg** to create the *BigJim* user
- Copy the **my.cnf** file to your **$HOME/.my.cnf** (note that it's hidden!)

#### Support Tools Setup
- Copy contents of https://github.com/captainkirk854/codeMusings-KornShell/tree/master/tools to a local directory of choice and ensure it is in $PATH
- Ensure that **../backend/tools** is also in $PATH

#### Building the **BIGGYM** database
- Create and populate the BIGGYM database using **rebuildBigGym.sh** found in **../backend/tools**
- Verify that data has been successfully ingested by selecting from the **BIGGYM.DEBUG_LOG** table.
  - e.g.
    - echo '**select * from BIGGYM.DEBUG_LOG order by DATE_REGISTERED desc;**' | mysql

## Conventions
### BIGGYM Database Internals
- **Lowercase Field Names** - some table(s) will have field names in lowercase. This is intended to denote that they are non-significant, i.e. that they are not tied to any unique index so a change in their value does not constitute a new row.
