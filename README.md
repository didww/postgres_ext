# PostgresExt

Note: this fork only supports CTEs, not the additional data types and query

## Installation

Add this line to your application's Gemfile:

    gem 'postgres_ext', github: 'SciMed/postgres_ext'

And then execute:

    $ bundle

## Usage

Just `require 'postgres_ext'` and use ActiveRecord as you normally would! postgres\_ext extends
ActiveRecord's data type handling and query methods in both Arel and
ActiveRecord.

### Common Table Expressions (CTEs)

Postgres\_ext adds CTE expression support to ActiveRecord via two
methods:

  * [`Relation#with`](#with)
  * [`Model.from_cte`](#from_cte)

## with

We can add CTEs to queries by chaining `#with` off a relation.
`Relation#with` accepts a hash, and will convert `Relation`s to the
proper SQL in the CTE.

Let's expand a `#with` call to its resulting SQL code:

```ruby
Score.with(my_games: Game.where(id: 1)).joins('JOIN my_games ON scores.game_id = my_games.id')
```

The following will be generated when that relation is evaluated:

```SQL
WITH my_games AS (
SELECT games.*
FROM games
WHERE games.id = 1
)
SELECT *
FROM scores
JOIN my_games
ON scores.games_id = my_games.id
```

You can also do a recursive with:

```ruby
Graph.with.recursive(search_graph:
  "  SELECT g.id, g.link, g.data, 1 AS depth
     FROM graph g
   UNION ALL
     SELECT g.id, g.link, g.data, sg.depth + 1
     FROM graph g, search_graph sg
     WHERE g.id = sg.link").from(:search_graph)
```

### from\_cte

`Model.from_cte` is similiar to `Model.find_by_sql`, taking the CTE
passed in, but allowing you to chain off of it further, instead of just
retrieving the results.

Take the following ActiveRecord call:

```ruby
Score.from_cte('scores_for_game', Score.where(game_id: 1)).where(user_id: 1)
```

The following SQL will be called:

```SQL
WITH scores_for_game AS (
SELECT *
FROM scores
WHERE game_id = 1
)
SELECT *
FROM scores_for_game
WHERE scores_for_game.user_id = 1
```

And will be converted to `Score` objects


## Developing

To work on postgres\_ext locally, follow these steps:

 1. Run `bundle install`, this will install (almost) all the development
    dependencies
 2. Run `bundle exec rake setup`, this will set up the `.env` file necessary to run
    the tests and set up the database
 3. Run `bundle exec rake db:create`, this will create the test database
 4. Run `bundle exec rake db:migrate`, this will set up the database tables required
    by the test
 5. Run `bundle exec rake test` to run tests

## Original Author

Dan McClain [twitter](http://twitter.com/_danmcclain) [github](http://github.com/danmcclain)
