# High Fives

A script to bring to light trends in your 15Five High Five data!

## Prerequisites

* [15Five](https://my.15five.com/) access
* Postgres
* Terminal access

## Usage

Navigate to [High Fives](https://my.15five.com/dashboard/high_fives/) in 15Five.
Export all data as a CSV and put in the project folder

![Export](docs/export.png)

Run this bash script from your terminal

`./high_fives_report.sh {name_of_file.csv}`

## Output

The script will generate output like the following:

```bash
--------------------------------------------------

There are 6143 high fives.

The first was created on 2019-05-02 18:42 by Fake Person.

The last was created on 2025-08-25 11:22 by Fake Person.

The most prolific high fivers are:

High Fiver       High Fives Given
Fake Person      776
Fake Person      372
Fake Person      369
Fake Person      326
Fake Person      280
Fake Person      250
Fake Person      240
Fake Person      240
Fake Person      216
Fake Person      214
(10 rows)

The top high five receivers are:

Receiver      High Fives Received
Fake Person   372
Fake Person   291
Fake Person   262
Fake Person   252
Fake Person   227
Fake Person   223
Fake Person   216
Fake Person   200
Fake Person   200
Fake Person   174
(10 rows)

The people who have been high fived by the most unique people are:

Receiver     Unique High Fivers  Total High Fivers
Fake Person  38                  60
Fake Person  38                  60
Fake Person  38                  60
Fake Person  37                  60
Fake Person  36                  60
Fake Person  33                  60
Fake Person  33                  60
Fake Person  32                  60
Fake Person  32                  60
Fake Person  32                  60
(10 rows)
--------------------------------------------------
```
