CREATE TABLE cars (
    id          BIGSERIAL PRIMARY KEY,
    model_name  VARCHAR(100) NOT NULL,
    series      VARCHAR(50)  NOT NULL,
    body_type   VARCHAR(50),
    fuel_type   VARCHAR(30),
    model_year  INTEGER,
    horsepower  INTEGER,
    price       NUMERIC(12,2) NOT NULL,
    description TEXT,
    image_url   VARCHAR(500),
    created_at  TIMESTAMP NOT NULL DEFAULT now()
);
