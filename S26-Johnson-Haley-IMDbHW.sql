/*
Query 1.) 10 POINTS

For each year from 2000 to 2009, calculate the total number and the average of
the ratings (rounded to 4 decimal places) of the movies that were released. The
output must be sorted by the average of the ratings in the decreasing order.

Should have 10 rows of output, that is 1 row for each year.

IMPORTANT REQUIREMENTS: Here you need to focus on the aggregation for
each year. For example, for output record corresponding to the total number and
average rating of movies released in 2000, you need to consider all movies that
have,
• startyear as 2000, and
• received at least 150000 votes
*/

SET LINESIZE 200
SET PAGESIZE 100
SET COLSEP '  '
COLUMN YEAR FORMAT A7

SELECT tb.startyear AS year, COUNT(*) AS TOTAL_MOVIES, ROUND(AVG(averagerating), 4) AS YEARLY_AVG
FROM imdb00.title_basics tb, imdb00.title_ratings tr
WHERE tb.tconst = tr.tconst
	AND tb.titletype = 'movie' 
	AND tb.startyear BETWEEN '2000' AND '2009'
	AND tr.numvotes >= 150000
GROUP BY tb.startyear
ORDER BY YEARLY_AVG DESC;

/*
YEAR     TOTAL_MOVIES  YEARLY_AVG
-------  ------------  ----------
2002               36      7.2667
2006               46      7.2152
2000               35      7.2029
2001               38      7.1395
2005               39      7.1256
2004               60      7.1183
2007               63      7.0857
2003               36      7.0833
2009               54      7.0815
2008               60      6.9583

10 rows selected.
*/

/*
Query 2.) 20 POINTS

Find the list of top tvseries along with the start year and its average rating. The
output must be sorted by the average of the ratings in the decreasing order.

IMPORTANT REQUIREMENTS: Here you need to focus on tvseries. A "top
tvseries" is a tvseries that has,
• an average rating of at least 8.0 across all its episodes, and
• received a total of at least 450000 votes across all its episodes.
*/

SET LINESIZE 200
SET PAGESIZE 100
SET COLSEP '  '
COLUMN TOP_TVSERIES FORMAT A28
COLUMN TVSERIES_STARTYEAR FORMAT A18
COLUMN AVG_TVSERIES_RATING FORMAT 9.99999999

SELECT tb.primarytitle AS TOP_TVSERIES, tb.startyear AS TVSERIES_STARTYEAR, AVG(tr.averagerating) AS AVG_TVSERIES_RATING
FROM imdb00.title_basics tb, imdb00.title_episode te, imdb00.title_ratings tr
WHERE tb.tconst = te.parenttconst
	AND te.tconst = tr.tconst
	AND tb.titletype = 'tvSeries'
GROUP BY tb.primarytitle, tb.startyear
HAVING AVG(tr.averagerating) >= 8.0
	AND SUM(tr.numvotes) >= 450000
ORDER BY AVG_TVSERIES_RATING DESC;

/*
TOP_TVSERIES                  TVSERIES_STARTYEAR  AVG_TVSERIES_RATING
----------------------------  ------------------  -------------------
Attack on Titan               2013                         9.08020833
Breaking Bad                  2008                         8.95161290
Better Call Saul              2015                         8.79500000
Game of Thrones               2011                         8.75068493
The Sopranos                  1999                         8.62209302
Stranger Things               2016                         8.60294118
Lost                          2004                         8.52100840
Regular Show                  2009                         8.48938776
Dexter                        2006                         8.48333333
House                         2004                         8.42954545
Rick and Morty                2013                         8.42745098
Supernatural                  2005                         8.37217125
Friends                       1994                         8.32212766
Seinfeld                      1989                         8.29942197
Arrow                         2012                         8.18058824
The Office                    2005                         8.09574468
How I Met Your Mother         2005                         8.02692308
Buffy the Vampire Slayer      1997                         8.00620690

18 rows selected.
*/

/*
Query 3.) 30 POINTS

For each year from 2005 to 2019 and for the Adventure genre, find out the lead
actor/actress names with the highest average rating. In case, there are multiple
actors/actresses with the same highest average rating, you need to display all of
them.

Should have at least 1 row for each year.

IMPORTANT REQUIREMENTS:
1. The average rating for an actor/actress is defined by the average rating of
the movies in which he/she has acted in.
2. Here, be careful while calculating each actor’s/actress’ average rating. For
example, for the output record corresponding to Adventure in 2005, you
need to ONLY consider those movies for every actor that have
	• startyear as 2005,
	• Adventure as at least one of the associated genres, (that is "Adventure", "Adventure,Drama", "Action,Adventure,Thriller", "Adventure,Fantasy,Romance", and so on qualify the requirement), and
	• have received at least 100000 votes.
3. Moreover, for this query you need to only consider lead actors/actresses
(someone is a lead actor/actress if the ordering attribute of the TITLE_PRINCIPALS table is equal to 1 or 2).
4. Finally, the output must be sorted by the year in increasing order.
*/

SET LINESIZE 200
SET PAGESIZE 100
SET COLSEP '  '
COLUMN YEAR FORMAT A10
COLUMN GENRE FORMAT A13
COLUMN MOST_POPULAR_ACTOR FORMAT A20

SELECT tb.startyear AS year,
	'Adventure' AS genre,
	AVG(tr.averagerating) AS highest_avg_actorrating,
	nb.primaryname AS most_popular_actor
FROM imdb00.title_basics tb,
	imdb00.title_ratings tr,
	imdb00.title_principals tp,
	imdb00.name_basics nb
WHERE tb.tconst = tr.tconst
	AND tb.tconst = tp.tconst
	AND tp.nconst = nb.nconst
	AND tb.titletype = 'movie'
	AND tb.startyear BETWEEN '2005' AND '2019'
	AND tb.genres LIKE '%Adventure%'
	AND tr.numvotes >= 100000
	AND tp.category IN ('actor', 'actress')
	AND tp.ordering IN ('1', '2')
GROUP BY tb.startyear, nb.nconst, nb.primaryname
HAVING AVG(tr.averagerating) =
(
		SELECT MAX(AVG(tr2.averagerating))
		FROM imdb00.title_basics tb2, imdb00.title_ratings tr2, imdb00.title_principals tp2, imdb00.name_basics nb2
		WHERE tb2.tconst = tr2.tconst
			AND tb2.tconst = tp2.tconst
			AND tp2.nconst = nb2.nconst
			AND tb2.titletype = 'movie'
        	AND tb2.startyear = tb.startyear
			AND tb2.genres LIKE '%Adventure%'
			AND tr2.numvotes >= 100000
			AND tp2.category IN ('actor', 'actress')
			AND tp2.ordering IN ('1', '2')
		GROUP BY nb2.nconst
	)
ORDER BY tb.startyear;

/*
YEAR        GENRE          HIGHEST_AVG_ACTORRATING  MOST_POPULAR_ACTOR
----------  -------------  -----------------------  --------------------
2005        Adventure                          7.8  Nathan Fillion
2005        Adventure                          7.8  Gina Torres
2006        Adventure                            8  Leonardo DiCaprio
2006        Adventure                            8  Djimon Hounsou
2006        Adventure                            8  Daniel Craig
2006        Adventure                            8  Eva Green
2007        Adventure                          8.1  Vince Vaughn
2007        Adventure                          8.1  Emile Hirsch
2008        Adventure                          8.4  Ben Burtt
2008        Adventure                          8.4  Elissa Knight
2009        Adventure                          8.3  Brad Pitt
2009        Adventure                          8.3  Edward Asner
2009        Adventure                          8.3  Diane Kruger
2009        Adventure                          8.3  Jordan Nagai
2010        Adventure                          8.8  Leonardo DiCaprio
2010        Adventure                          8.8  Joseph Gordon-Levitt
2011        Adventure                          8.1  Daniel Radcliffe
2011        Adventure                          8.1  Emma Watson
2012        Adventure                            8  Robert Downey Jr.
2012        Adventure                            8  Chris Evans
2013        Adventure                          7.8  Ian McKellen
2013        Adventure                          7.8  Martin Freeman
2014        Adventure                          8.6  Matthew McConaughey
2014        Adventure                          8.6  Anne Hathaway
2015        Adventure                          8.2  Bill Hader
2015        Adventure                          8.2  Amy Poehler
2016        Adventure                            8  Jason Bateman
2016        Adventure                            8  Ryan Reynolds
2016        Adventure                            8  Ginnifer Goodwin
2016        Adventure                            8  Morena Baccarin
2017        Adventure                          8.4  Gael Garcia Bernal
2017        Adventure                          8.4  Anthony Gonzalez
2018        Adventure                          8.4  Robert Downey Jr.
2018        Adventure                          8.4  Chris Hemsworth
2018        Adventure                          8.4  Jake Johnson
2018        Adventure                          8.4  Shameik Moore
2019        Adventure                          8.4  Robert Downey Jr.
2019        Adventure                          8.4  Chris Evans

38 rows selected.
*/