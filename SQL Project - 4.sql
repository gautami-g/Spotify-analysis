-- Advanced SQL Project - Spotify Project

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

-- ------------------------------------------
-- EDA
-- ------------------------------------------

SELECT COUNT(*) FROM spotify;

SELECT COUNT (DISTINCT artist) FROM spotify;

SELECT COUNT (DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT DISTINCT channel FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min)FROM spotify;

select * from spotify
where duration_min = 0;

delete from spotify
where duration_min = 0
select * from spotify
where duration_min = 0;

-- ------------------------------------------
-- Data Analysis - Easy Category ---
-- ------------------------------------------

-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify
where stream > 1000000000;

-- 2.List all albums along with their respective artists.
select album, artist from spotify;

-- 3.Get the total number of comments for tracks where licensed = TRUE.
select sum(comments)from spotify
where licensed = true;

-- 4.Find all tracks that belong to the album type single.
select * from spotify 
where album_type = 'single';

-- 5.Count the total number of tracks by each artist.
select artist , count(*) as total_songs
from spotify
group by artist
order by 2 desc;

-- ------------------------------------------
-- Data Analysis - Medium Category ----
-- ------------------------------------------

-- 1.Calculate the average danceability of tracks in each album.
select album, avg(danceability) as avg_danceability
from spotify
group by 1
order by 2 desc;

-- 2.Find the top 5 tracks with the highest energy values.
select track, avg(energy) 
from spotify
group by 1
order by 2 desc limit 5;

-- 3.List all tracks along with their views and likes where official_video = TRUE.
select track,
sum(views) as total_views,
sum(likes)as total_likes 
from spotify
where official_video = true
group by 1
order by 2 desc limit 5;

-- 4.For each album, calculate the total views of all associated tracks.
select album,track,
sum(views) as total_views 
from spotify
group by album,track
order by 3 desc;

-- 5.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from
(select track,
	coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
	coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
from spotify
group by 1
) as streamed
where streamed_on_youtube < streamed_on_spotify
and streamed_on_youtube <> 0;

---------------------------------------------
-- Data Analysis - Advanced Category ----
---------------------------------------------

-- 1.Find the top 3 most-viewed tracks for each artist using window functions.
with artists_rank
as
(select 
	artist,track,
	sum(views)as total_view, 
	dense_rank()over(partition by artist order by sum(views) desc)as rank
from spotify
group by 1,2
order by 1,3 desc
)
select * from artists_rank
where rank <=3;

-- 2.Write a query to find tracks where the liveness score is above the average.
select 
	track, 
	artist,
	liveness 
from spotify
where liveness >(select avg(liveness) from spotify);

-- 3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with energy_diff 
as
(select album,
	max(energy)as higest_energy,
	min(energy)as lowest_energy
from spotify
group by 1
)
select album,
	higest_energy - lowest_energy as difference
from energy_diff
order by 2 desc;

-- 4.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track
from spotify
where (energy / nullif(liveness, 0)) > 1.2;

-- 5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select track, 
	sum(likes) over(order by views)as cummulative_likes
from spotify




