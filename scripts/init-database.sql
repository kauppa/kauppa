/* Create users */

CREATE USER IF NOT EXISTS kauppa;
CREATE USER IF NOT EXISTS kauppa_accounts;
CREATE USER IF NOT EXISTS kauppa_cart;
CREATE USER IF NOT EXISTS kauppa_coupon;
CREATE USER IF NOT EXISTS kauppa_orders;
CREATE USER IF NOT EXISTS kauppa_products;
CREATE USER IF NOT EXISTS kauppa_shipments;
CREATE USER IF NOT EXISTS kauppa_tax;

/* Create databases */

CREATE DATABASE IF NOT EXISTS kauppa_accounts;
CREATE DATABASE IF NOT EXISTS kauppa_cart;
CREATE DATABASE IF NOT EXISTS kauppa_coupon;
CREATE DATABASE IF NOT EXISTS kauppa_orders;
CREATE DATABASE IF NOT EXISTS kauppa_products;
CREATE DATABASE IF NOT EXISTS kauppa_shipments;
CREATE DATABASE IF NOT EXISTS kauppa_tax;

/* Grant privileges */

GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_accounts TO kauppa_accounts;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_cart TO kauppa_cart;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_coupon TO kauppa_coupon;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_orders TO kauppa_orders;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_products TO kauppa_products;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_shipments TO kauppa_shipments;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_tax TO kauppa_tax;
GRANT CREATE,SELECT,INSERT,UPDATE,DELETE ON DATABASE kauppa_accounts, kauppa_cart, kauppa_coupon, kauppa_orders, kauppa_products, kauppa_shipments, kauppa_tax TO kauppa;
