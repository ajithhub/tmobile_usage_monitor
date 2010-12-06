
DROP TABLE users;
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    first_name TEXT,
                    full_name  TEXT,
                    username   TEXT,
                    is_prepaid INTEGER,
                    timestamp  INTEGER);

DROP  TABLE usage_history;
CREATE  TABLE usage_history (
                           id INTEGER PRIMARY KEY AUTOINCREMENT,
                           user_id INTEGER,
                           expiration INTEGER,
                           minutes NUMERIC,
                           messages NUMERIC,
                           balance  NUMERIC,
                           timestamp INTEGER
                    );
             

