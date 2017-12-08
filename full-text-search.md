1. Materialized view

    CREATE MATERIALIZED VIEW entries_search AS
    SELECT ,
      CASE WHEN type='twitter_fav' THEN (content ->> 'screen_name') || (content ->> 'text')
           WHEN type='github_star' THEN (content ->> 'owner') || (content ->> 'name') || (content ->> 'description')
           WHEN type='pinboard_link' THEN (content ->> 'description')
           ELSE ''
      END AS flat_text
    FROM entries

2. Search index

    create index "idx_flat_text" on entries_search using gin(to_tsvector('english', flat_text));

3. Query example

This will match all words starting with `post`

    select id, content from entries_search where to_tsvector('english', flat_text) @@ to_tsquery('post:*');
