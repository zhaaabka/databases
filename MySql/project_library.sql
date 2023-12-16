-- создание таблицы пользователя

CREATE TABLE IF NOT EXISTS Users (
  user_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  first_name CHAR(50) NOT NULL,
  last_name CHAR(50) NOT NULL
);

INSERT INTO Users VALUES (NULL, 'Anastasia', 'Alekseeva');
INSERT INTO Users VALUES (NULL, 'Anastasia', 'Ivanova');
INSERT INTO Users VALUES (NULL, 'Timofey', 'Dedov');
INSERT INTO Users VALUES (NULL, 'Sofya', 'Voitova');
INSERT INTO Users VALUES (NULL, 'Rinchin', 'Abiduev');


-- создание таблицы библиотек

CREATE TABLE IF NOT EXISTS Libraries (
  library_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  library_name CHAR(100) NOT NULL,
  adress CHAR(200) NOT NULL,
  working_hours CHAR(50) NOT NULL
);


INSERT INTO Libraries VALUES (NULL, 'HSE University Library on Myasnitskaya', 'Moscow, Myasnitskaya ulitsa, 20', 'Mon-Sat, 10-23');
INSERT INTO Libraries VALUES (NULL, 'HSE Central Library', 'Moscow, Pokrovsky boulevard, 11, building N', 'Mon-Sun, 24/7');
INSERT INTO Libraries VALUES (NULL, 'HSE University Library on Staraya Basmannaya, building B', 'Moscow, 21/4 Staraya Basmannaya Ulitsa, building B', 'Mon-Sat, 10-23');
INSERT INTO Libraries VALUES (NULL, 'HSE University Library on Shabolovka', 'Moscow, 28/11 Shabolovka Ulitsa, Building 2', 'Mon-Sat, 10-21');


-- создание таблицы книг

CREATE TABLE IF NOT EXISTS Books (
  book_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  book_name CHAR(100) NOT NULL,
  author CHAR(100) NOT NULL,
  publisher CHAR(100) NOT NULL,
  publishing_year INTEGER NOT NULL,
  amount_available INTEGER NOT NULL
);


-- создание таблицы заказов

CREATE TABLE IF NOT EXISTS BookOrders (
  order_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  is_returned BOOL NOT NULL,
  order_date DATE NOT NULL,
  due_date DATE NOT NULL,
  date_of_return DATE,
  id_overdue BOOL NOT NULL,
  user_id INTEGER,
  library_id INTEGER,
  book_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES Users (user_id),
  FOREIGN KEY (library_id) REFERENCES Libraries (library_id),
  FOREIGN KEY (book_id) REFERENCES Books (book_id)
);


-- создание таблицы книга-библиотека

CREATE TABLE BookLibraries (
  book_library_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  amount INTEGER,
  library_id INTEGER,
  book_id INTEGER,
  FOREIGN KEY (library_id) REFERENCES Libraries (library_id),
  FOREIGN KEY (book_id) REFERENCES Books (book_id)
);


-- добавляем книги

INSERT INTO Books VALUES (NULL, 'Pride and Prejudice', 'Jane Austen', 'Penguin', 2012, 0);
INSERT INTO Books VALUES (NULL, 'To Kill a Mockingbird', 'Harper Lee', 'Arrow', 2015, 0);
INSERT INTO Books VALUES (NULL, 'One Hundred Years of Solitude', 'Gabriel García Márquez', 'Penguin', 2014, 0);
INSERT INTO Books VALUES (NULL, 'War and Peace', 'Lev Tolstoy', 'Penguin', 2009, 0);
INSERT INTO Books VALUES (NULL, 'The Brothers Karamazov', 'Fyodor Dostoyevsky', 'Vintage Books', 2004, 0);


-- Read (CRUD):

SELECT * FROM Books;


-- триггер, который обновляет кол-во книг в таблице книг при добавлении строки в таблице книги-библиотеки

DELIMITER //
DROP TRIGGER IF EXISTS total_books_insert //
CREATE TRIGGER total_books_insert AFTER INSERT ON BookLibraries
  FOR EACH ROW
    BEGIN
    UPDATE Books 
    SET amount_available = (SELECT SUM(amount) FROM BookLibraries WHERE book_id = NEW.book_id)
    WHERE book_id = NEW.book_id;
  END //
DELIMITER ;

-- триггер, который обновляет кол-во книг в таблице книг при обновлении кол-ва в таблице книги-библиотеки

DELIMITER //
DROP TRIGGER IF EXISTS total_books //
CREATE TRIGGER total_books AFTER UPDATE ON BookLibraries
  FOR EACH ROW
    BEGIN
    UPDATE Books 
    SET amount_available = (SELECT SUM(amount) FROM BookLibraries WHERE book_id = NEW.book_id)
    WHERE book_id = NEW.book_id;
  END //
DELIMITER ;


-- добавляем книги в библиотеки

INSERT INTO BookLibraries VALUES (NULL, 1, 1, 1);
INSERT INTO BookLibraries VALUES (NULL, 1, 1, 3);
INSERT INTO BookLibraries VALUES (NULL, 1, 1, 4);
INSERT INTO BookLibraries VALUES (NULL, 1, 1, 5);

INSERT INTO BookLibraries VALUES (NULL, 3, 2, 1);
INSERT INTO BookLibraries VALUES (NULL, 5, 2, 2);
INSERT INTO BookLibraries VALUES (NULL, 4, 2, 3);
INSERT INTO BookLibraries VALUES (NULL, 3, 2, 4);
INSERT INTO BookLibraries VALUES (NULL, 4, 2, 5);

INSERT INTO BookLibraries VALUES (NULL, 5, 3, 2);
INSERT INTO BookLibraries VALUES (NULL, 4, 3, 3);
INSERT INTO BookLibraries VALUES (NULL, 9, 3, 4);
INSERT INTO BookLibraries VALUES (NULL, 8, 3, 5);

INSERT INTO BookLibraries VALUES (NULL, 2, 4, 4);
INSERT INTO BookLibraries VALUES (NULL, 2, 4, 5);

SELECT * FROM Books;

-- триггер, если добавляем новый заказ, уменьшить число доступных книг в библиотеке на 1

DELIMITER //
DROP TRIGGER IF EXISTS lib_books_insert //
CREATE TRIGGER lib_books_insert AFTER INSERT ON BookOrders
  FOR EACH ROW
    BEGIN
    UPDATE BookLibraries 
    SET amount = amount - 1
    WHERE book_id = NEW.book_id AND library_id = NEW.library_id;
  END //
DELIMITER ;

-- добавим заказ

INSERT INTO BookOrders VALUES (NULL, 0, '2023-12-16', '2024-01-15', NULL, 0, 1, 1, 3);
INSERT INTO BookOrders VALUES (NULL, 0, '2023-12-16', '2024-01-15', NULL, 0, 2, 2, 5);
INSERT INTO BookOrders VALUES (NULL, 0, '2023-12-16', '2024-01-15', NULL, 0, 3, 2, 4);
INSERT INTO BookOrders VALUES (NULL, 0, '2023-12-16', '2024-01-15', NULL, 0, 4, 3, 4);

-- триггер, если пользователь вернул книгу (is_returned = 1), увеличить число доступных книг на 1

SELECT * FROM Books;

DELIMITER //
DROP TRIGGER IF EXISTS lib_books //
CREATE TRIGGER lib_books AFTER UPDATE ON BookOrders
  FOR EACH ROW
    BEGIN
    UPDATE BookLibraries 
    SET amount = amount + 1
    WHERE book_id = NEW.book_id AND library_id = NEW.library_id AND NEW.is_returned = 1;
  END //
DELIMITER ;

-- Update (CRUD). пользователь вернул книгу

UPDATE BookOrders
SET is_returned = 1, date_of_return = '2023-12-29' WHERE order_id = 2;

-- УДАЛЕНИЕ КНИГИ

DELIMITER //
DROP TRIGGER IF EXISTS books_del //
CREATE TRIGGER books_del BEFORE DELETE ON Books
  FOR EACH ROW
    BEGIN
    DELETE FROM BookLibraries WHERE book_id = OLD.book_id;
  END //
DELIMITER ;

-- Delete (CRUD). Удаляем книгу из базы

DELETE FROM Books WHERE book_id = 1;





-- SELECT + фильтрация

SELECT * FROM Books WHERE publishing_year > 2010;


-- SELECT + группировка и агрегация. ID библиотек и общее число книг в них.

SELECT library_id, SUM(amount) number_of_books FROM BookLibraries
GROUP BY library_id;


-- SELECT + вложенный запрос. Книги, которые заказывали.

SELECT book_id, book_name FROM Books
WHERE book_id IN (SELECT book_id FROM BookOrders);


-- SELECT + JOIN + что-то. Названия и адреса библиотек, где общее кол-во книг > X.

SELECT library_name, adress, number_of_books from Libraries
JOIN (SELECT library_id, SUM(amount) number_of_books FROM BookLibraries GROUP BY library_id) AS libs
ON Libraries.library_id = libs.library_id
WHERE number_of_books > 5;


-- Процедура или функция. Выводим пары библиотека-книга, в которых этой конкретной книги больше Х

DELIMITER //
DROP PROCEDURE IF EXISTS amount_books_more_than//
CREATE PROCEDURE amount_books_more_than(IN amount_books INTEGER, id_book INTEGER)
BEGIN
  SELECT * FROM BookLibraries WHERE amount > amount_books AND book_id = id_book;
END//
DELIMITER ;

CALL amount_books_more_than(@amount_books := 2, @book_id := 5);
