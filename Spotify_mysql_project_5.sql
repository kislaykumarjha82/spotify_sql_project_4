-- Advance Sql Project Spotify
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
select * from spotify;
select count(* ) from spotify;
select count(Distinct album ) from spotify;
select count(Distinct artist ) from spotify;
select Distinct album_type  from spotify;
select max(duration_min )from spotify;
select min(duration_min )from spotify;
select  * from spotify where duration_min =0;
delete from spotify where duration_min =0;
select  distinct channel from spotify;
select  distinct most_played_on from spotify;

------------------------------------------------
-- data Analysis Easy Category
------------------------------------------------
/*Easy Level
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.*/


-- Qno.1 Retrieve the names of all tracks that have more than 1 billion streams?
select * from spotify where stream>1000000000;
--Qno.2 List all albums along with their respective artists?
select Distinct album,artist from spotify order by 1;
--Qno.3 Get the total number of comments for tracks where licensed = TRUE?
select sum(comments) as total_comments from spotify where licensed ='true';
--Qno.4 Find all tracks that belong to the album type single?
select * from spotify
where album_type ilike 'single';
--Qno.5 Count the total number of tracks by each artist?
select artist,
count(*) as total_no_song 
from spotify
group by  artist;



------------------------------------------------
-- data Analysis Medium Category
------------------------------------------------
/*Medium Level
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.*/


--Qno .6Calculate the average danceability of tracks in each album?
select album , 
avg(danceability) as avg_danceability 
from spotify 
group by 1 
order by 2 desc;
--Qno.7 Find the top 5 tracks with the highest energy values?
select  track, MAX(energy)
from spotify
group by 1
order by 2 desc
limit 5;
--Qno.8 List all tracks along with their views and likes where official_video = TRUE?
select  track,
sum(views) as total_views, 
sum(likes) as total_views
from spotify
where official_video ='true'
group by 1
order by 2 desc;
--Qno.9For each album, calculate the total views of all associated tracks?
 select 
 album,
 track,
 sum(views)
 from spotify
 group by 1,2
 order by 3 desc;
--Qno.10 Retrieve the track names that have been streamed on Spotify more than YouTube?
select * from 
(select 
track,
--most_played_on,
Coalesce(sum(case when most_played_on ='Youtube' then stream end),0) as streamed_on_youtube,
Coalesce(sum(case when most_played_on ='spotify' then stream end),0) as streamed_on_spotify
from spotify
group by 1)as t1
where streamed_on_spotify>streamed_on_youtube
and streamed_on_spotify<>0 ;

------------------------------------------------
-- data Analysis Advance Category
------------------------------------------------

/*Advanced Level
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.*/

--Qno.11 Find the top 3 most-viewed tracks for each artist using window functions?
--eack artist and total view for each track
--track with highest view for each artist(we need top)
--dense rank
--cte and filderbrank<=3
with ranking_artist as
    (select 
     artist,
     track,
     sum(views) as total_view,
     dense_rank()over(PARTITION BY artist ORDER BY SUM(VIEWS)DESC) as rank
     from spotify
     group by 1,2
     order by 1,3 Desc)
select * from ranking_artist where rank<=3;

--Qno.12 Write a query to find tracks where the liveness score is above the average?
select track,
artist,
liveness
from spotify where liveness>(select avg(liveness) from spotify);

--Qno.13 Use a WITH clause to calculate the difference between the 
--highest and lowest energy values for tracks in each album?
with cte as 
(select 
album,
max(energy) as highest_energy,
max(energy) as lowest_energy
from spotify 
group by 1)
select album , 
highest_energy - lowest_energy as energy_diff
from cte
order by 2 desc;



---Queary Optimization 
EXPLAIN ANALYSIS --et 7.97 ms pt 0.112ms
select artist,track,views from spotify
where artist = 'Gorillaz' and most_played_on = 'Youtube'
order by stream desc limit 25;

create index artist_index on spotify (artist);

