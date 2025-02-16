# Spotify-Advanced-SQL-Project-and-Query-Optimization

![2024-spotify-brand-assets-media-kit](https://github.com/user-attachments/assets/6d6027a3-98cc-42ce-aa82-6b5e70897958)


## Project Overview
**Project Title:**  Spotify SQL Project and Query Optimization

This project focuses on analyzing a Spotify dataset containing detailed information about tracks, albums, and artists using SQL. It involves the complete process of transforming a denormalized dataset into a normalized structure, executing SQL queries of varying complexity (ranging from basic to advanced), and optimizing query performance. The main objectives are to refine advanced SQL skills and extract meaningful insights from the data.

## Technology Stack
- **Data Preparation & Loading** - Microsoft Excel
- **DBMS:** PostgreSQL 
- **Query Language:** SQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions 

## Data Source
- Dataset was downloaded from [Maven Analytics](www.maven.com)

## Project Objectives  
1. **Schemas Setup** – Establish Schemas and populate using the provided data.
2.**Data Exploration:** - Examine and understand dataset to identify patterns, trends and relationships in the data.
3. **Querying the Data** – Conduct an initial analysis to gain insights into the dataset's structure and key trends. Utilize SQL queries to address critical business questions and extract meaningful insights from the sales data.
4. **Query Optimization** - In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:


## Dataset Description
Before diving into SQL, it’s essential to have a clear understanding of the dataset. It includes attributes such as: 
- **Artist:** The performer of the track.
- **Track:** The name of the song.
- **Album:** The album to which the track belongs.
- **Album_type:** The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

  ### 1. SCHEMA Setup
- **Database Creation:** The project begins with setting up a database named `spotify_db`.  
- **Table Creation:** Create all neccesary table to store required data.
```sql
-- create table

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM spotify
```
### 2. Data Exploration
Examine and understanding dataset before performing deeper analysis or modeling to identify patterns, trends, anomalies, and relationships in the data.
```sql
SELECT COUNT (*)
FROM spotify;

SELECT DISTINCT artist
FROM spotify;

SELECT DISTINCT album
FROM spotify;

SELECT DISTINCT album_type
FROM spotify;

SELECT MAX (duration_min)
FROM spotify;

SELECT MIN (duration_min)
FROM spotify;

SELECT * 
FROM spotify
WHERE duration_min = 0;

-- DELETE songs with no values

DELETE
FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel
FROM spotify
```
### 3. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. 

**Retrieve the names of all tracks that have more than 1 billion streams.**
```sql
SELECT *
FROM spotify 
WHERE stream > 1000000000
```

**List all albums along with their respective artists.**
```sql
SELECT DISTINCT artist,
	album
FROM spotify;
```
**Get the total number of comments for tracks where licensed = TRUE**
```sql
SELECT SUM(comments)
FROM spotify
WHERE licensed = TRUE;
```
**Find all tracks that belong to the album type single**
```sql
SELECT *
FROM spotify
WHERE album_type = 'single';
```
**Count the total number of tracks by each artist.**
```sql
SELECT DISTINCT artist,
	COUNT (*)
FROM spotify
GROUP BY artist;
```
**Calculate the average danceability of tracks in each album.**
```sql
SELECT 
    track, 
    album, 
    AVG(danceability) OVER (PARTITION BY album) AS average_danceability
FROM spotify
WHERE album_type = 'album';
```
**Find the top 5 tracks with the highest energy values.**
```sql
SELECT *
FROM spotify 
ORDER BY energy DESC
	LIMIT 5;
```
**List all tracks along with their views and likes where official_video = TRUE**
```sql
SELECT track,
	views,
	likes
FROM spotify
WHERE official_video = 'TRUE'
```
**For each album, calculate the total views of all associated tracks.**
```sql
SELECT album,
	SUM(views)
FROM (
		SELECT 
			track, 
			album, 
			views 
		FROM spotify
		WHERE album_type = 'album'
		ORDER BY 2
	)sub
GROUP BY 1;
```
**Retrieve the track names that have been streamed on Spotify more than YouTube.**
```sql
WITH spotify AS 
			(
			SELECT 
				track,
				SUM (stream) spotify_streams
			FROM spotify
			WHERE most_played_on = 'Spotify'
			GROUP BY track),
youtube AS 
			(
			SELECT 
				track,
				SUM (stream) youtube_streams
			FROM spotify
			WHERE most_played_on = 'Youtube'
			GROUP BY track)

SELECT *
FROM spotify
WHERE track IN (
    SELECT s1.track
    FROM (
        SELECT 
            track,
            SUM(stream) AS spotify_streams
        FROM spotify
        WHERE most_played_on = 'Spotify'
        GROUP BY track
    ) s1
    JOIN (
        SELECT 
            track,
            SUM(stream) AS youtube_streams
        FROM spotify
        WHERE most_played_on = 'Youtube'
        GROUP BY track
    ) s2
    ON s1.track = s2.track
    WHERE s1.spotify_streams > s2.youtube_streams
);
```
**Find the top 3 most-viewed tracks for each artist using window functions.**
```sql
SELECT *
FROM (
		SELECT artist,
		track,
		views,
		RANK () OVER (PARTITION BY artist ORDER BY views DESC) track_rank
	FROM spotify) sub
WHERE track_rank BETWEEN 1 AND 3
```
**Write a query to find tracks where the liveness score is above the average.**
```sql	
SELECT *
FROM spotify
WHERE liveness > (SELECT AVG(liveness) 
					FROM spotify)
```
**Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH t1 AS (
    SELECT 
        album,
        MAX(energy) AS max_energy_per_album,
        MIN(energy) AS min_energy_per_album
    FROM spotify
    GROUP BY album
)
SELECT 
    album,
    max_energy_per_album - min_energy_per_album AS energy_difference
FROM t1
ORDER BY energy_difference DESC;
```
**Find tracks where the energy-to-liveness ratio is greater than 1.2**
```sql
SELECT *
FROM (
	SELECT track,
		energy,
		liveness,
		energy/liveness AS energy_liveness_ratio
	FROM spotify)
WHERE energy_liveness_ratio > 1.2
```
**Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**
```sql
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_sum
FROM spotify
ORDER BY views DESC;
```
---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

- This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Data Preparation & Loading** - Microsoft Excel
- **DBMS:** PostgreSQL 
- **Query Language:** SQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions 

---

## 📌 About Me
Hi, I'm Oluwatosin Amosu Bolaji, a Data Analyst skilled in SQL, Power BI, and Excel. I enjoy turning complex datasets into actionable insights through data visualization and business intelligence techniques.

- **🔹 Key Skills:** Data Analysis | SQL Queries | Power BI Dashboards | Data Cleaning | Reporting
- **🔹 Passionate About:** Data storytelling, problem-solving, and continuous learning

- **📫 Let's connect!**
- 🔗 [Linkedin](www.linkedin.com/in/oluwatosin-amosu-722b88141) | 🌐 [Portfolio](https://github.com/Tbrown1998?tab=repositories) | 📩 oluwabolaji60@gmail.com
