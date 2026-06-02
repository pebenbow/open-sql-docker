-- Run from the repo root:
--   duckdb duckdb/northwind.duckdb -f scripts/northwind_to_duckdb.sql
--
-- Note: photo/picture BYTEA columns are stored as empty strings in the source
-- files and are loaded as VARCHAR here.

CREATE TABLE region (
    region_id          INTEGER PRIMARY KEY,
    region_description VARCHAR
);

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name VARCHAR,
    description   VARCHAR,
    picture       VARCHAR
);

CREATE TABLE customer_demographics (
    customer_type_id VARCHAR PRIMARY KEY,
    customer_desc    VARCHAR
);

CREATE TABLE customers (
    customer_id   VARCHAR PRIMARY KEY,
    company_name  VARCHAR,
    contact_name  VARCHAR,
    contact_title VARCHAR,
    address       VARCHAR,
    city          VARCHAR,
    region        VARCHAR,
    postal_code   VARCHAR,
    country       VARCHAR,
    phone         VARCHAR,
    fax           VARCHAR
);

CREATE TABLE shippers (
    shipper_id   INTEGER PRIMARY KEY,
    company_name VARCHAR,
    phone        VARCHAR
);

CREATE TABLE suppliers (
    supplier_id   INTEGER PRIMARY KEY,
    company_name  VARCHAR,
    contact_name  VARCHAR,
    contact_title VARCHAR,
    address       VARCHAR,
    city          VARCHAR,
    region        VARCHAR,
    postal_code   VARCHAR,
    country       VARCHAR,
    phone         VARCHAR,
    fax           VARCHAR,
    homepage      VARCHAR
);

CREATE TABLE us_states (
    state_id     INTEGER PRIMARY KEY,
    state_name   VARCHAR,
    state_abbr   VARCHAR,
    state_region VARCHAR
);

CREATE TABLE employees (
    employee_id        INTEGER PRIMARY KEY,
    last_name          VARCHAR,
    first_name         VARCHAR,
    title              VARCHAR,
    title_of_courtesy  VARCHAR,
    birth_date         DATE,
    hire_date          DATE,
    address            VARCHAR,
    city               VARCHAR,
    region             VARCHAR,
    postal_code        VARCHAR,
    country            VARCHAR,
    home_phone         VARCHAR,
    extension          VARCHAR,
    photo              VARCHAR,
    notes              VARCHAR,
    reports_to         INTEGER,
    photo_path         VARCHAR
);

CREATE TABLE territories (
    territory_id          VARCHAR PRIMARY KEY,
    territory_description VARCHAR,
    region_id             INTEGER
);

CREATE TABLE products (
    product_id        INTEGER PRIMARY KEY,
    product_name      VARCHAR,
    supplier_id       INTEGER,
    category_id       INTEGER,
    quantity_per_unit VARCHAR,
    unit_price        DECIMAL(10,2),
    units_in_stock    INTEGER,
    units_on_order    INTEGER,
    reorder_level     INTEGER,
    discontinued      INTEGER
);

CREATE TABLE customer_customer_demo (
    customer_id      VARCHAR,
    customer_type_id VARCHAR,
    PRIMARY KEY (customer_id, customer_type_id)
);

CREATE TABLE employee_territories (
    employee_id  INTEGER,
    territory_id VARCHAR,
    PRIMARY KEY (employee_id, territory_id)
);

CREATE TABLE orders (
    order_id          INTEGER PRIMARY KEY,
    customer_id       VARCHAR,
    employee_id       INTEGER,
    order_date        DATE,
    required_date     DATE,
    shipped_date      DATE,
    ship_via          INTEGER,
    freight           DECIMAL(10,2),
    ship_name         VARCHAR,
    ship_address      VARCHAR,
    ship_city         VARCHAR,
    ship_region       VARCHAR,
    ship_postal_code  VARCHAR,
    ship_country      VARCHAR
);

CREATE TABLE order_details (
    order_id   INTEGER,
    product_id INTEGER,
    unit_price DECIMAL(9,2),
    quantity   INTEGER,
    discount   DECIMAL(5,2),
    PRIMARY KEY (order_id, product_id)
);

COPY region                 FROM 'databases/northwind/region.txt'                 (DELIMITER '|', HEADER true);
COPY categories             FROM 'databases/northwind/categories.txt'             (DELIMITER '|', HEADER true);
COPY customer_demographics  FROM 'databases/northwind/customer_demographics.txt'  (DELIMITER '|', HEADER true);
COPY customers              FROM 'databases/northwind/customers.txt'              (DELIMITER '|', HEADER true);
COPY shippers               FROM 'databases/northwind/shippers.txt'               (DELIMITER '|', HEADER true);
COPY suppliers              FROM 'databases/northwind/suppliers.txt'              (DELIMITER '|', HEADER true);
COPY us_states              FROM 'databases/northwind/us_states.txt'              (DELIMITER '|', HEADER true);
COPY employees              FROM 'databases/northwind/employees.txt'              (DELIMITER '|', HEADER true);
COPY territories            FROM 'databases/northwind/territories.txt'            (DELIMITER '|', HEADER true);
COPY products               FROM 'databases/northwind/products.txt'               (DELIMITER '|', HEADER true);
COPY customer_customer_demo FROM 'databases/northwind/customer_customer_demo.txt' (DELIMITER '|', HEADER true);
COPY employee_territories   FROM 'databases/northwind/employee_territories.txt'   (DELIMITER '|', HEADER true);
COPY orders                 FROM 'databases/northwind/orders.txt'                 (DELIMITER '|', HEADER true);
COPY order_details          FROM 'databases/northwind/order_details.txt'          (DELIMITER '|', HEADER true);
