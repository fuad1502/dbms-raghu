-- Create tables

CREATE TABLE Address (
	name VARCHAR,
	phone_number INT,
	UNIQUE (phone_number),
	PRIMARY KEY (name)
);

CREATE TABLE Instrument (
	name VARCHAR,
	key VARCHAR,
	PRIMARY KEY (name, key)
);

CREATE TABLE Musician (
	ssn INT,
	name VARCHAR,
	address_name VARCHAR NOT NULL,
	instrument_name VARCHAR,
	instrument_key VARCHAR,
	PRIMARY KEY (ssn),
	FOREIGN KEY (address_name) REFERENCES Address(name)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	FOREIGN KEY (instrument_name, instrument_key) REFERENCES Instrument(name, key)
		ON DELETE NO ACTION
		ON UPDATE CASCADE
);

CREATE TABLE Song (
	title VARCHAR,
	author VARCHAR,
	PRIMARY KEY (title, author)
);

CREATE TABLE Album (
	id INT,
	title VARCHAR,
	copyright_date DATE,
	format VARCHAR,
	produced_by INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (produced_by) REFERENCES Musician(ssn)
		ON DELETE NO ACTION
		ON UPDATE CASCADE
);

CREATE TABLE AlbumSongs (
	album_id INT,
	song_title VARCHAR,
	song_author VARCHAR,
	FOREIGN KEY (album_id) REFERENCES Album(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (song_title, song_author) REFERENCES Song(title, author)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	PRIMARY KEY (song_title, song_author)
);

CREATE TABLE Performed (
	song_title VARCHAR,
	song_author VARCHAR,
	musician_ssn INT,
	FOREIGN KEY (song_title, song_author) REFERENCES Song(title, author),
	FOREIGN KEY (musician_ssn) REFERENCES Musician(ssn)
);

-- Define additional constraints

CREATE FUNCTION check_album_has_songs()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM AlbumSongs WHERE album_id = NEW.id) THEN
		RETURN NEW;
	ELSE 
		RAISE EXCEPTION 'Album does not contain any songs';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER album_insert
    AFTER INSERT ON Album
    DEFERRABLE
    FOR EACH ROW
    EXECUTE FUNCTION check_album_has_songs();

CREATE FUNCTION delete_empty_album()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM AlbumSongs WHERE album_id = OLD.album_id) THEN
		DELETE FROM Album WHERE id = OLD.album_id;
		RETURN OLD;
	ELSE
		RETURN OLD;
	END IF;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER albumsongs_delete
    AFTER DELETE ON AlbumSongs
    DEFERRABLE
    FOR EACH ROW
    EXECUTE FUNCTION delete_empty_album();

-- Insert sample values

-- INSERT INTO Address VALUES ('Kemanggisan', 123);
-- INSERT INTO Instrument VALUES ('Guitar', 'E');
-- INSERT INTO Musician VALUES (456, 'Fuad', 'Kemanggisan', 'Guitar', 'E');
-- INSERT INTO Song VALUES ('Bilbob', 'Umay');
-- BEGIN;
-- SET CONSTRAINTS album_insert DEFERRED;
-- INSERT INTO Album VALUES (1, 'Bilbob Collections', TO_DATE('07/05/22','DD/MM/YY'), 'CD', 456);
-- INSERT INTO AlbumSongs VALUES (1, 'Bilbob', 'Umay');
-- COMMIT;
