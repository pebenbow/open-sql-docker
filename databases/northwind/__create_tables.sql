CREATE SCHEMA IF NOT EXISTS public;

-- region
CREATE TABLE public.region (
    region_description VARCHAR(60),
    region_id SMALLINT PRIMARY KEY
);

-- categories
CREATE TABLE public.categories (
    category_name VARCHAR(15),
    description TEXT,
    picture BYTEA,
    category_id SMALLINT PRIMARY KEY
);

-- customer_demographics
CREATE TABLE public.customer_demographics (
    customer_desc TEXT,
    customer_type_id VARCHAR(5) PRIMARY KEY
);

-- customers
CREATE TABLE public.customers (
    company_name VARCHAR(40),
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    customer_id VARCHAR(5) PRIMARY KEY
);

-- shippers
CREATE TABLE public.shippers (
    company_name VARCHAR(40),
    phone VARCHAR(24),
    shipper_id SMALLINT PRIMARY KEY
);

-- suppliers
CREATE TABLE public.suppliers (
    company_name VARCHAR(40),
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    homepage TEXT,
    supplier_id SMALLINT PRIMARY KEY
);

-- us_states
CREATE TABLE public.us_states (
    state_name VARCHAR(100),
    state_abbr VARCHAR(2),
    state_region VARCHAR(50),
    state_id SMALLINT PRIMARY KEY
);

-- employees
CREATE TABLE public.employees (
    last_name VARCHAR(20),
    first_name VARCHAR(10),
    title VARCHAR(30),
    title_of_courtesy VARCHAR(25),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    home_phone VARCHAR(24),
    extension VARCHAR(4),
    photo BYTEA,
    notes TEXT,
    reports_to SMALLINT,
    photo_path VARCHAR(255),
    employee_id SMALLINT PRIMARY KEY,
    CONSTRAINT fk_employees_reports_to
        FOREIGN KEY (reports_to) REFERENCES public.employees (employee_id)
);

-- territories
CREATE TABLE public.territories (
    territory_description VARCHAR(60),
    region_id SMALLINT,
    territory_id VARCHAR(20) PRIMARY KEY,
    CONSTRAINT fk_territories_region_id
        FOREIGN KEY (region_id) REFERENCES public.region (region_id)
);

-- products
CREATE TABLE public.products (
    product_name VARCHAR(40),
    supplier_id SMALLINT,
    category_id SMALLINT,
    quantity_per_unit VARCHAR(20),
    unit_price NUMERIC(10,2),
    units_in_stock SMALLINT,
    units_on_order SMALLINT,
    reorder_level SMALLINT,
    discontinued INTEGER,
    product_id SMALLINT PRIMARY KEY,
    CONSTRAINT fk_products_supplier_id
        FOREIGN KEY (supplier_id) REFERENCES public.suppliers (supplier_id),
    CONSTRAINT fk_products_category_id
        FOREIGN KEY (category_id) REFERENCES public.categories (category_id)
);

-- customer_customer_demo
CREATE TABLE public.customer_customer_demo (
    customer_id VARCHAR(5),
    customer_type_id VARCHAR(5),
    PRIMARY KEY (customer_id, customer_type_id),
    CONSTRAINT fk_customer_customer_demo_customer_id
        FOREIGN KEY (customer_id) REFERENCES public.customers (customer_id),
    CONSTRAINT fk_customer_customer_demo_customer_type_id
        FOREIGN KEY (customer_type_id) REFERENCES public.customer_demographics (customer_type_id)
);

-- employee_territories
CREATE TABLE public.employee_territories (
    employee_id SMALLINT,
    territory_id VARCHAR(20),
    PRIMARY KEY (employee_id, territory_id),
    CONSTRAINT fk_employee_territories_employee_id
        FOREIGN KEY (employee_id) REFERENCES public.employees (employee_id),
    CONSTRAINT fk_employee_territories_territory_id
        FOREIGN KEY (territory_id) REFERENCES public.territories (territory_id)
);

-- orders
CREATE TABLE public.orders (
    customer_id VARCHAR(5),
    employee_id SMALLINT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via SMALLINT,
    freight NUMERIC(10,2),
    ship_name VARCHAR(40),
    ship_address VARCHAR(60),
    ship_city VARCHAR(15),
    ship_region VARCHAR(15),
    ship_postal_code VARCHAR(10),
    ship_country VARCHAR(15),
    order_id SMALLINT PRIMARY KEY,
    CONSTRAINT fk_orders_customer_id
        FOREIGN KEY (customer_id) REFERENCES public.customers (customer_id),
    CONSTRAINT fk_orders_employee_id
        FOREIGN KEY (employee_id) REFERENCES public.employees (employee_id),
    CONSTRAINT fk_orders_ship_via
        FOREIGN KEY (ship_via) REFERENCES public.shippers (shipper_id)
);

-- order_details
CREATE TABLE public.order_details (
    unit_price NUMERIC(9,2),
    quantity SMALLINT,
    discount NUMERIC(3,2),
    order_id SMALLINT,
    product_id SMALLINT,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_details_order_id
        FOREIGN KEY (order_id) REFERENCES public.orders (order_id),
    CONSTRAINT fk_order_details_product_id
        FOREIGN KEY (product_id) REFERENCES public.products (product_id)
);
