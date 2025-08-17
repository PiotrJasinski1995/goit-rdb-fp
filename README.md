# goit-rdb-fp

1. Upload the Data:
- Create a schema called pandemic in the database using an SQL command.
- Set it as the default schema using an SQL command.
- Import the data using the Import Wizard, just as you did in Topic 3.
infectious_cases.csv

2. Normalise the infectious_cases Table. Save two tables with normalised data in the same schema.

3. Analyse the Data:
- For each unique combination of Entity and Code, or their id, calculate the average, minimum, maximum, and sum for the attribute Number_rabies.
- Sort the result by the calculated average in descending order.
- Select only 10 rows to display on the screen.

4. Construct the Year Difference Column.

For the original or normalised table, create the following using built-in SQL functions for the Year column:
- An attribute that creates the first of January of the respective year:
- An attribute that equals the current date.
- An attribute that equals the difference in years between the two columns mentioned above.

5. Create Your Own Function.

Create and use a function that constructs the same attribute as in the previous task. The function should take a year value as input and return the difference in years between the current date and the date created from the year attribute (e.g., 1996 → '1996-01-01').
