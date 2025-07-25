#Spotify Advanced SQL Project and Query Optimization

<img width="1024" height="583" alt="spotify logo" src="https://github.com/user-attachments/assets/6c1b4f42-7b03-4820-9a15-346734a2612a" />



## Overview

This project demonstrates advanced SQL techniques on a Spotify dataset, covering the entire data analysis workflow: table creation, data cleaning, easy-to-advanced SQL queries, and query optimization. It is designed to strengthen SQL query writing, performance tuning, and analytical thinking.

## Dataset

* **Source**: [Spotify Dataset on Kaggle](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)
* The dataset contains details such as track name, artist, album, audio features (e.g., energy, danceability), views, streams, likes, comments, and platforms where the tracks were most played.

---

## Table Schema

```sql
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
```

---

## Data Cleaning

* Removed records where `duration_min = 0`
* Verified distinct values in columns such as `album_type`, `channel`, and `most_played_on`

---

## SQL Analysis

### Easy Level Queries

1. **Tracks with over 1 billion streams**

```sql
SELECT * FROM spotify WHERE stream > 1000000000;
```

2. **List albums with respective artists**

```sql
SELECT DISTINCT album, artist FROM spotify ORDER BY album;
```

3. **Total comments for licensed tracks**

```sql
SELECT SUM(comments) FROM spotify WHERE licensed = 'true';
```

4. **Tracks from album type 'single'**

```sql
SELECT * FROM spotify WHERE album_type ILIKE 'single';
```

5. **Track count per artist**

```sql
SELECT artist, COUNT(*) AS total_no_song FROM spotify GROUP BY artist;
```

---

### Medium Level Queries

6. **Average danceability per album**

```sql
SELECT album, AVG(danceability) AS avg_danceability FROM spotify GROUP BY album ORDER BY avg_danceability DESC;
```

7. **Top 5 tracks by energy**

```sql
SELECT track, MAX(energy) FROM spotify GROUP BY track ORDER BY MAX(energy) DESC LIMIT 5;
```

8. **Official videos with views and likes**

```sql
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes FROM spotify WHERE official_video = 'true' GROUP BY track ORDER BY total_views DESC;
```

9. **Total views per album**

```sql
SELECT album, track, SUM(views) FROM spotify GROUP BY album, track ORDER BY SUM(views) DESC;
```

10. **Tracks streamed more on Spotify than YouTube**

```sql
SELECT * FROM (
    SELECT track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY track
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube AND streamed_on_spotify <> 0;
```

---

### Advanced Level Queries

11. **Top 3 most-viewed tracks per artist**

```sql
WITH ranking_artist AS (
    SELECT artist, track, SUM(views) AS total_view,
           DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
    FROM spotify
    GROUP BY artist, track
)
SELECT * FROM ranking_artist WHERE rank <= 3;
```

12. **Tracks where liveness is above average**

```sql
SELECT track, artist, liveness FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

13. **Difference between highest and lowest energy in each album**

```sql
WITH cte AS (
    SELECT album, MAX(energy) AS highest_energy, MIN(energy) AS lowest_energy
    FROM spotify GROUP BY album
)
SELECT album, highest_energy - lowest_energy AS energy_diff FROM cte ORDER BY energy_diff DESC;
```

14. **Tracks where energy-to-liveness ratio > 1.2**

```sql
SELECT track, artist, energy, liveness,
       (energy / NULLIF(liveness, 0)) AS energy_liveness_ratio
FROM spotify
WHERE (energy / NULLIF(liveness, 0)) > 1.2;
```

15. **Cumulative likes ordered by views using window functions**

```sql
SELECT track, artist, views, likes,
       SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM spotify
WHERE likes IS NOT NULL AND views IS NOT NULL
ORDER BY views DESC;
```

---

## Query Optimization

### Problem:

Initial query to retrieve tracks by artist `'Gorillaz'` had execution time of **7.97 ms**

```sql
EXPLAIN ANALYZE
SELECT artist, track, views FROM spotify
WHERE artist = 'Gorillaz' AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;
```

### Solution:

Created an index on the `artist` column:

```sql
CREATE INDEX artist_index ON spotify (artist);
```

### Result:

Execution time reduced significantly after index creation. This demonstrates how indexing can greatly improve query performance in large datasets.

---

## How to Run the Project

1. Install MySQL or PostgreSQL and a compatible SQL editor (e.g., MySQL Workbench or pgAdmin).
2. Create the table using the schema provided.
3. Load the cleaned dataset (`cleaned_dataset.csv`).
4. Run queries based on the question sets.
5. Test query optimization using `EXPLAIN ANALYZE`.

---

## Next Steps

* Build Power BI or Tableau dashboards using query results
* Add user-level data for personalized recommendation insights
* Scale the dataset and measure optimization impact further

---

