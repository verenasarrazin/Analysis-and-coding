# Journal Ranking Database

I recently completed a [Code First Girls](https://codefirstgirls.com/) course on SQL to extend my programming knowledge. As project work for the course, I created a database using the [Journal Ranking Dataset](https://www.kaggle.com/datasets/xabirhasan/journal-ranking-dataset) from kaggle.com. The dataset contains information about hundreds of journals from different research areas, including number of published documents, number of citations, quality indices, country, etc. I wrote the following script to create the database:

- <a href="https://verenasarrazin.github.io/Analysis-and-coding/Project_journal_ranking.html" title="Journal Ranking Database (SQL)">Journal Ranking Database (SQL)</a>

*The script includes*
- **primary and foreign keys**
- **queries with subqueries** (where, group by, inner join)
- **functions** (calculate Pearson correlation between two variables)
- a **stored procedure** (to insert new entries)
- a **trigger** (to save the time and date of new entries)

The structure of the database is summarised in the following EER diagram:

<img src="https://github.com/verenasarrazin/Analysis-and-coding/assets/73107031/9367bb38-b3b1-4a45-8839-15aebab71ddc" alt="drawing" width="700"/>
