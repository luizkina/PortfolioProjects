Data source and meaning of labels for each column in the original table:
https://ess.sikt.no/en/datafile/242aaa39-3bbb-40f5-98bf-bfb1ce53d8ef/110?tab=0

The objective of using this dataset is to analyze what could influence the happiness of the population that was polled.

Before importing the data to MySQL, I edited information that was not necessary directly on excel as to both speed up the upload to MySQL Server and to not run any problems with formatting.
The edits that were done:

    - Change data to the expected date format in SQL, change from text (20.06.2024) to date using 'DATE()' and 'RIGHT()', 'MIDDLE()' and 'LEFT()' to expected date format (yyyy-mm-dd).

    - Remove the party voted in last election (prtvt*), as there are many different countries with differing parties and ideologies, as well as which party they feel closer to (prtc*).

    - Remove all other categories (other than gender (gndr)) as they do not pertain directly to the analysis of this project.

With those changes, I saved the new .csv directly to the MySQL data folder into the table, named ess, that was created.

Due to the use of MySQL Workbench, there was no way to directly transfer the tables that were selected from the sql queries. So each labeled prompt was saved to a table on Excel and then a visualization was created on Tableau.

On the SQL file, first there was a check for any null values and there wasn't.
Then a query was created for finding the distribution of each gender on each country.
After that, there was a query for happiness acording to: the country, the political leaning (left or right) and gender.

Since the poll could feature values over 10 if the person didn't know, didn't answer or refused to respond, there was a filter for it on each of the queries. On the lrscale (scale of left to right leaning), the value could also be over 10 for the same reasons as the happiness poll. Regarding the gender, there were 3 possible values, 1 was male, 2 was female and 9 was a non answer. Finally, regarding the time of internet use, the answers could be invalid for the same reasons as stated before. But since the time of internet use could vary from 0 to 1000, it was decided to group them in groups of 30 minutes. Since the really high values didn't have enough data (sometimes 1 or 2 people), there was a filter created that each group had to have at least 10 people. 