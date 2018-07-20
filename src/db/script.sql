
CREATE TABLE IF NOT EXISTS NOTES (
id TEXT PRIMARY KEY,
title TEXT,
body TEXT,
color TEXT,
fav INT,
pin INT,
addDate DATE,
updated DATE
);

CREATE TABLE IF NOT EXISTS BOOKS (
url TEXT PRIMARY KEY,
title TEXT NOT NULL,
fav INTEGER NOT NULL,
addDate DATE
);

CREATE TABLE IF NOT EXISTS LINKS (
link TEXT PRIMARY KEY,
url TEXT,
title TEXT,
preview TEXT,
color TEXT,
fav INT,
pin INT,
addDate DATE,
updated DATE
);
