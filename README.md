# Database-Lab-Project
This repository contains the project done for the database laboratory, a course taken during the bachelor's degree in computer science.
## Goal of the project
The aim of the project is the creation of a database for the management of a wholesale goods market.
In particular, we want to keep track of the orders placed by the various departments with suppliers and with the various customers at the market. You also want to keep track of suppliers, people belonging to various departments and customers.
## Architecture

* Inside the *Python* folder we find the code for generating the .sql file for the initial population of the database.

* Inside the *R* folder we find the code for generating the graphs.

* Inside the *SQL* folder we find a file for defining tables, triggers and indexes, and a file for querying the most frequent operations.
## Documentation

The pdf file is a detailed report (written in Italian) which contains:
* The analysis of the requirements, with the glossary of terms and the operations carried out on the data
* The conceptual design, with the Entity-Relationship schema and the various design decisions
* Logical design, with the analysis of redundancies, the choice of primary keys and the translation of the ER schema into the relational schema
* The physical design, with creating the tables, inserting the random data, creating the indexes, creating the triggers
* Data analysis, with all graphs produced with R
