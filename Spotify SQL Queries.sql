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

--- EDA

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

-- EDA

SELECT DISTINCT channel
FROM spotify

-- DATA ANALYSIS & PROBLEMS SOLVING

/* Retrieve the names of all tracks that have more than 1 billion streams.
*/

SELECT *
FROM spotify 
WHERE stream > 1000000000

/* List all albums along with their respective artists.
*/

SELECT DISTINCT artist,
	album
FROM spotify;

/* Get the total number of comments for tracks where licensed = TRUE
*/

SELECT SUM(comments)
FROM spotify
WHERE licensed = TRUE;

/* Find all tracks that belong to the album type single
*/

SELECT *
FROM spotify
WHERE album_type = 'single';

/* Count the total number of tracks by each artist.
*/

SELECT DISTINCT artist,
	COUNT (*)
FROM spotify
GROUP BY artist;

/* Calculate the average danceability of tracks in each album.
*/

SELECT 
    track, 
    album, 
    AVG(danceability) OVER (PARTITION BY album) AS average_danceability
FROM spotify
WHERE album_type = 'album';

/* Find the top 5 tracks with the highest energy values.
*/

SELECT *
FROM spotify 
ORDER BY energy DESC
	LIMIT 5;

/* List all tracks along with their views and likes where official_video = TRUE
*/

SELECT track,
	views,
	likes
FROM spotify
WHERE official_video = 'TRUE'

/* For each album, calculate the total views of all associated tracks.
*/

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

/* Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

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

/* Find the top 3 most-viewed tracks for each artist using window functions.
*/

SELECT *
FROM (
		SELECT artist,
		track,
		views,
		RANK () OVER (PARTITION BY artist ORDER BY views DESC) track_rank
	FROM spotify) sub
WHERE track_rank BETWEEN 1 AND 3

/* Write a query to find tracks where the liveness score is above the average.
*/
	
SELECT *
FROM spotify
WHERE liveness > (SELECT AVG(liveness) 
					FROM spotify)

/* Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
*/

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

/*Find tracks where the energy-to-liveness ratio is greater than 1.2.
*/

SELECT *
FROM (
	SELECT track,
		energy,
		liveness,
		energy/liveness AS energy_liveness_ratio
	FROM spotify)
WHERE energy_liveness_ratio > 1.2

/*Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_sum
FROM spotify
ORDER BY views DESC;




















