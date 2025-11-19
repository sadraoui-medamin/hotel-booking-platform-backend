-- Create separate databases for each service
CREATE DATABASE auth_db;
CREATE DATABASE hotels_db;
CREATE DATABASE bookings_db;
CREATE DATABASE payments_db;
CREATE DATABASE reviews_db;
CREATE DATABASE loyalty_db;
CREATE DATABASE chat_db;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE auth_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE hotels_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE bookings_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE payments_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE reviews_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE loyalty_db TO hotel_user;
GRANT ALL PRIVILEGES ON DATABASE chat_db TO hotel_user;

-- Enable UUID extension on all databases
\c auth_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c hotels_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c bookings_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c payments_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c reviews_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c loyalty_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c chat_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";