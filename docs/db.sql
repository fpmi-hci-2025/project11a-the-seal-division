-- Создание базы данных book_shop
CREATE DATABASE book_shop;
\c book_shop;

-- Создание таблицы ролей
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Создание таблицы пользователей
CREATE TABLE "user" (
    user_id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- Создание таблицы учетных данных
CREATE TABLE credentials (
    credential_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

-- Создание таблицы издательств
CREATE TABLE publisher (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100)
);

-- Создание таблицы категорий (иерархическая)
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INTEGER,
    CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) REFERENCES category(category_id)
);

-- Создание таблицы авторов
CREATE TABLE author (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    birth_date DATE
);

-- Создание таблицы книг
CREATE TABLE book (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_date DATE,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    page_count INTEGER CHECK (page_count > 0),
    preorder BOOLEAN DEFAULT FALSE,
    availability_date DATE,
    addition_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    language VARCHAR(50) DEFAULT 'Русский',
    in_stock INTEGER NOT NULL DEFAULT 0 CHECK (in_stock >= 0),
    publisher_id INTEGER NOT NULL,
    CONSTRAINT fk_publisher FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

-- Создание таблицы связи книга-автор
CREATE TABLE book_author (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
);

-- Создание таблицы связи книга-категория
CREATE TABLE book_category (
    book_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
);

-- Создание таблицы скидок
CREATE TABLE discount (
    discount_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_percent NUMERIC(5,2) NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date >= start_date)
);

-- Создание таблицы связи книга-скидка
CREATE TABLE book_discount (
    book_id INTEGER NOT NULL,
    discount_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, discount_id),
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_discount FOREIGN KEY (discount_id) REFERENCES discount(discount_id) ON DELETE CASCADE
);

-- Создание таблицы заказов
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(50) NOT NULL DEFAULT 'новый',
    address VARCHAR(256) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES "user"(user_id)
);

-- Создание таблицы позиций заказа
CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_per_unit NUMERIC(10,2) NOT NULL CHECK (price_per_unit >= 0),
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(book_id)
);

-- Создание таблицы отзывов
CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES "user"(user_id),
    UNIQUE (book_id, customer_id)
);

-- Создание индексов для улучшения производительности
CREATE INDEX idx_book_title ON book(title);
CREATE INDEX idx_book_isbn ON book(isbn);
CREATE INDEX idx_book_price ON book(price);
CREATE INDEX idx_book_in_stock ON book(in_stock);
CREATE INDEX idx_author_name ON author(last_name, first_name);
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_order_customer ON "order"(customer_id);
CREATE INDEX idx_order_date ON "order"(order_date);
CREATE INDEX idx_order_status ON "order"(status);
CREATE INDEX idx_review_book ON review(book_id);
CREATE INDEX idx_review_rating ON review(rating);

INSERT INTO role (name) VALUES 
('customer'),
('administrator');
