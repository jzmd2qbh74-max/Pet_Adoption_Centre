-- ============================================================
-- CS306 Database Management – Project: Pet Adoption Centre
-- ============================================================

-- ============================================================
-- DATABASE SETUP
-- ============================================================

DROP DATABASE IF EXISTS pet_adoption_centre;
CREATE DATABASE pet_adoption_centre;
USE pet_adoption_centre;

-- ============================================================
-- TABLE DEFINITIONS (5 tables, normalized to 3NF)
-- ============================================================

-- Table 1: Shelters
-- Stores information about shelter locations/branches
CREATE TABLE Shelter (
    shelter_id    INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(200) NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    capacity      INT          NOT NULL CHECK (capacity > 0)
);

-- Table 2: Pets
-- Core entity – each animal in the adoption system
CREATE TABLE Pet (
    pet_id        INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(50)  NOT NULL,
    species       ENUM('Dog','Cat','Rabbit','Bird','Other') NOT NULL,
    breed         VARCHAR(100),
    age_years     DECIMAL(4,1) NOT NULL CHECK (age_years >= 0),
    gender        ENUM('Male','Female','Unknown') NOT NULL DEFAULT 'Unknown',
    status        ENUM('Available','Pending','Adopted','Quarantine') NOT NULL DEFAULT 'Available',
    intake_date   DATE         NOT NULL,
    shelter_id    INT          NOT NULL,
    CONSTRAINT fk_pet_shelter FOREIGN KEY (shelter_id) REFERENCES Shelter(shelter_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Table 3: Medical Records
-- Tracks vaccinations, treatments, and vet visits per pet
CREATE TABLE MedicalRecord (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    pet_id          INT          NOT NULL,
    record_date     DATE         NOT NULL,
    vet_name        VARCHAR(100) NOT NULL,
    diagnosis       VARCHAR(300),
    treatment       VARCHAR(300),
    vaccinated      TINYINT(1)   NOT NULL DEFAULT 0,
    vaccine_name    VARCHAR(100),
    next_checkup    DATE,
    CONSTRAINT fk_medical_pet FOREIGN KEY (pet_id) REFERENCES Pet(pet_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Table 4: Adopters
-- People who apply to adopt pets
CREATE TABLE Adopter (
    adopter_id    INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    address       VARCHAR(200) NOT NULL,
    housing_type  ENUM('House','Apartment','Farm','Other') NOT NULL,
    has_yard      TINYINT(1)   NOT NULL DEFAULT 0,
    has_children  TINYINT(1)   NOT NULL DEFAULT 0,
    registered_on DATE         NOT NULL
);

-- Table 5: Adoption Requests
-- Links adopters to pets; tracks the adoption lifecycle
CREATE TABLE AdoptionRequest (
    request_id      INT AUTO_INCREMENT PRIMARY KEY,
    adopter_id      INT          NOT NULL,
    pet_id          INT          NOT NULL,
    request_date    DATE         NOT NULL,
    status          ENUM('Pending','Approved','Rejected','Completed') NOT NULL DEFAULT 'Pending',
    approval_date   DATE,
    notes           TEXT,
    CONSTRAINT fk_request_adopter FOREIGN KEY (adopter_id) REFERENCES Adopter(adopter_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_request_pet FOREIGN KEY (pet_id) REFERENCES Pet(pet_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- Business rule: one active request per pet at a time
    CONSTRAINT uq_active_request UNIQUE (pet_id, status)
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Shelters (5 rows)
INSERT INTO Shelter (name, address, phone, email, capacity) VALUES
('Happy Paws Main',    '12 Elm Street, Sarajevo',       '+387-33-100-001', 'main@happypaws.ba',     60),
('Furry Friends North','45 Oak Avenue, Banja Luka',     '+387-51-200-002', 'north@furryfriends.ba', 40),
('Shelter Mostar',     '7 Rose Lane, Mostar',           '+387-36-300-003', 'info@sheltermostar.ba', 35),
('City Animal Care',   '88 Pine Road, Tuzla',           '+387-35-400-004', 'care@cityac.ba',        50),
('Green Meadow Rescue','3 Valley Drive, Zenica',        '+387-32-500-005', 'rescue@greenmeadow.ba', 45);

-- Pets (15 rows, distributed across shelters)
INSERT INTO Pet (name, species, breed, age_years, gender, status, intake_date, shelter_id) VALUES
('Max',     'Dog',    'Labrador Retriever', 3.0,  'Male',   'Available',   '2024-01-15', 1),
('Bella',   'Cat',    'Domestic Shorthair', 2.0,  'Female', 'Available',   '2024-02-10', 1),
('Charlie', 'Dog',    'German Shepherd',    5.0,  'Male',   'Adopted',     '2023-11-20', 1),
('Luna',    'Cat',    'Persian',            1.5,  'Female', 'Available',   '2024-03-01', 2),
('Rocky',   'Dog',    'Beagle',             4.0,  'Male',   'Pending',     '2024-01-28', 2),
('Daisy',   'Rabbit', 'Holland Lop',        1.0,  'Female', 'Available',   '2024-02-20', 2),
('Leo',     'Cat',    'Maine Coon',         3.5,  'Male',   'Available',   '2024-03-05', 3),
('Mia',     'Dog',    'Golden Retriever',   2.5,  'Female', 'Available',   '2024-02-15', 3),
('Buddy',   'Dog',    'Poodle',             6.0,  'Male',   'Quarantine',  '2024-03-10', 3),
('Coco',    'Cat',    'Siamese',            4.0,  'Female', 'Available',   '2024-01-05', 4),
('Zara',    'Dog',    'Husky',              2.0,  'Female', 'Available',   '2024-02-25', 4),
('Pepper',  'Bird',   'Budgerigar',         0.5,  'Unknown','Available',   '2024-03-15', 4),
('Bruno',   'Dog',    'Rottweiler',         7.0,  'Male',   'Adopted',     '2023-10-10', 5),
('Lily',    'Cat',    'Bengal',             1.0,  'Female', 'Available',   '2024-03-20', 5),
('Oreo',    'Rabbit', 'Mini Rex',           2.0,  'Male',   'Available',   '2024-02-05', 5);

-- Medical Records (15 rows – at least 3 per pet with foreign key linkage)
INSERT INTO MedicalRecord (pet_id, record_date, vet_name, diagnosis, treatment, vaccinated, vaccine_name, next_checkup) VALUES
(1,  '2024-01-16', 'Dr. Alic',    'Healthy',            'Deworming',             1, 'Rabies, DHPP',     '2024-07-16'),
(1,  '2024-02-20', 'Dr. Alic',    'Minor ear infection','Antibiotic ear drops',  0, NULL,               '2024-04-20'),
(1,  '2024-04-01', 'Dr. Besic',   'Healthy follow-up',  'None required',         0, NULL,               '2024-10-01'),
(2,  '2024-02-11', 'Dr. Colic',   'Healthy',            'Flea treatment',        1, 'FVRCP',            '2024-08-11'),
(2,  '2024-03-15', 'Dr. Colic',   'URI mild',           'Antibiotics 7 days',    0, NULL,               '2024-04-15'),
(2,  '2024-04-10', 'Dr. Alic',    'Recovered from URI', 'None',                  0, NULL,               '2024-10-10'),
(4,  '2024-03-02', 'Dr. Djordic', 'Healthy',            'Routine checkup',       1, 'FVRCP, Rabies',    '2024-09-02'),
(4,  '2024-03-20', 'Dr. Djordic', 'Dental tartar',      'Dental scaling',        0, NULL,               '2025-03-20'),
(4,  '2024-04-05', 'Dr. Djordic', 'Post-dental review', 'None',                  0, NULL,               '2024-10-05'),
(5,  '2024-01-29', 'Dr. Efendic', 'Healthy',            'Deworming, flea treat', 1, 'Rabies, DHPP',     '2024-07-29'),
(5,  '2024-02-28', 'Dr. Efendic', 'Limping right paw',  'Rest, anti-inflammatory',0,NULL,               '2024-03-28'),
(5,  '2024-03-28', 'Dr. Efendic', 'Paw healed',         'None',                  0, NULL,               '2024-09-28'),
(9,  '2024-03-11', 'Dr. Alic',    'Kennel cough',       'Antibiotics, isolation',0, NULL,               '2024-04-11'),
(9,  '2024-03-25', 'Dr. Alic',    'Improving',          'Continue antibiotics',   0, NULL,               '2024-04-25'),
(9,  '2024-04-11', 'Dr. Alic',    'Fully recovered',    'Clear for adoption',     1, 'Bordetella',       '2024-10-11');

-- Adopters (8 rows)
INSERT INTO Adopter (first_name, last_name, email, phone, address, housing_type, has_yard, has_children, registered_on) VALUES
('Amira',   'Hodzic',    'amira.hodzic@email.ba',   '+387-61-111-001', '5 Maršala Tita, Sarajevo',   'Apartment', 0, 0, '2024-01-20'),
('Emir',    'Kovac',     'emir.kovac@email.ba',     '+387-62-222-002', '22 Obala, Banja Luka',       'House',     1, 1, '2024-02-01'),
('Lejla',   'Mujic',     'lejla.mujic@email.ba',    '+387-63-333-003', '9 Brace Fejica, Mostar',     'House',     1, 0, '2024-02-12'),
('Dino',    'Selimovic', 'dino.selimovic@email.ba', '+387-64-444-004', '14 Rudarska, Tuzla',         'Apartment', 0, 1, '2024-02-18'),
('Sara',    'Begic',     'sara.begic@email.ba',     '+387-65-555-005', '3 Zenicka, Zenica',          'House',     1, 0, '2024-03-01'),
('Adnan',   'Petrovic',  'adnan.petrovic@email.ba', '+387-66-666-006', '77 Himze Polovine, Sarajevo','Apartment', 0, 0, '2024-03-10'),
('Maja',    'Ivic',      'maja.ivic@email.ba',      '+387-67-777-007', '11 Vuka Karadzica, Tuzla',   'House',     1, 1, '2024-03-15'),
('Tarik',   'Zukic',     'tarik.zukic@email.ba',    '+387-68-888-008', '60 Splitska, Mostar',        'Farm',      1, 0, '2024-03-22');

-- Adoption Requests (10 rows)
INSERT INTO AdoptionRequest (adopter_id, pet_id, request_date, status, approval_date, notes) VALUES
(1, 2,  '2024-02-15', 'Completed', '2024-02-18', 'Adopter lives alone, apartment suitable for a cat.'),
(2, 3,  '2023-12-01', 'Completed', '2023-12-05', 'Large house with yard, perfect for German Shepherd.'),
(3, 1,  '2024-04-10', 'Pending',   NULL,          'Background check in progress.'),
(4, 4,  '2024-03-10', 'Approved',  '2024-03-12', 'Persian cat suitable for apartment; approval granted.'),
(5, 5,  '2024-02-28', 'Pending',   NULL,          'Awaiting vet clearance for pet.'),
(6, 7,  '2024-03-20', 'Approved',  '2024-03-22', 'Maine Coon matches applicant lifestyle.'),
(7, 8,  '2024-03-18', 'Pending',   NULL,          'Reference check ongoing.'),
(8, 13, '2023-11-01', 'Completed', '2023-11-05', 'Farm environment ideal for Rottweiler.'),
(1, 10, '2024-04-15', 'Rejected',  '2024-04-16', 'Applicant already has an active adoption; reapply later.'),
(6, 14, '2024-04-20', 'Pending',   NULL,          'First-time adopter; home visit scheduled.');

-- ============================================================
-- CRUD OPERATIONS
-- ============================================================

-- INSERT: Add a new pet to the system
INSERT INTO Pet (name, species, breed, age_years, gender, status, intake_date, shelter_id)
VALUES ('Simba', 'Cat', 'Abyssinian', 1.5, 'Male', 'Available', CURDATE(), 1);

-- INSERT: Register a new adopter
INSERT INTO Adopter (first_name, last_name, email, phone, address, housing_type, has_yard, has_children, registered_on)
VALUES ('Nina', 'Babic', 'nina.babic@email.ba', '+387-61-999-009', '2 Nova Street, Sarajevo', 'House', 1, 0, CURDATE());

-- UPDATE: Change pet status when adoption is completed
UPDATE Pet
SET status = 'Adopted'
WHERE pet_id = 4;

-- UPDATE: Approve a pending adoption request
UPDATE AdoptionRequest
SET status = 'Approved', approval_date = CURDATE()
WHERE request_id = 3;

-- DELETE: Remove a rejected request that is no longer needed
DELETE FROM AdoptionRequest
WHERE status = 'Rejected' AND request_id = 9;

-- ============================================================
-- SELECT QUERIES (variety: joins, subqueries, operators)
-- ============================================================

-- 1. Basic SELECT: All available pets with their shelter names
SELECT
    p.pet_id,
    p.name        AS pet_name,
    p.species,
    p.breed,
    p.age_years,
    p.gender,
    s.name        AS shelter_name,
    s.address     AS shelter_address
FROM Pet p
JOIN Shelter s ON p.shelter_id = s.shelter_id
WHERE p.status = 'Available'
ORDER BY p.species, p.name;

-- 2. INNER JOIN: Pending adoption requests with adopter and pet details
SELECT
    ar.request_id,
    ar.request_date,
    CONCAT(a.first_name, ' ', a.last_name) AS adopter_name,
    a.email                                 AS adopter_email,
    p.name                                  AS pet_name,
    p.species,
    p.breed,
    ar.status
FROM AdoptionRequest ar
INNER JOIN Adopter a ON ar.adopter_id = a.adopter_id
INNER JOIN Pet     p ON ar.pet_id     = p.pet_id
WHERE ar.status = 'Pending'
ORDER BY ar.request_date;

-- 3. LEFT JOIN: All pets and their most recent medical record (if any)
SELECT
    p.pet_id,
    p.name            AS pet_name,
    p.species,
    mr.record_date    AS last_visit,
    mr.vet_name,
    mr.diagnosis,
    mr.vaccinated,
    mr.next_checkup
FROM Pet p
LEFT JOIN MedicalRecord mr ON p.pet_id = mr.pet_id
  AND mr.record_date = (
      SELECT MAX(m2.record_date)
      FROM MedicalRecord m2
      WHERE m2.pet_id = p.pet_id
  )
ORDER BY p.pet_id;

-- 4. Subquery: Pets that have NEVER had a medical record
SELECT pet_id, name, species, status, intake_date
FROM Pet
WHERE pet_id NOT IN (
    SELECT DISTINCT pet_id FROM MedicalRecord
);

-- 5. Special operators (BETWEEN, LIKE, IN): Pets aged 1–4, dog or cat, available
SELECT name, species, breed, age_years, gender, status
FROM Pet
WHERE age_years BETWEEN 1 AND 4
  AND species IN ('Dog', 'Cat')
  AND status = 'Available'
ORDER BY age_years;

-- 6. Multi-table JOIN: Complete adoption history with all parties
SELECT
    ar.request_id,
    CONCAT(a.first_name,' ',a.last_name)  AS adopter,
    a.housing_type,
    p.name                                 AS pet,
    p.species,
    p.breed,
    s.name                                 AS shelter,
    ar.request_date,
    ar.approval_date,
    ar.status
FROM AdoptionRequest ar
JOIN Adopter a  ON ar.adopter_id  = a.adopter_id
JOIN Pet     p  ON ar.pet_id      = p.pet_id
JOIN Shelter s  ON p.shelter_id   = s.shelter_id
ORDER BY ar.request_date DESC;

-- 7. Subquery with EXISTS: Adopters who have at least one completed adoption
SELECT
    a.adopter_id,
    CONCAT(a.first_name,' ',a.last_name) AS adopter_name,
    a.email,
    a.housing_type
FROM Adopter a
WHERE EXISTS (
    SELECT 1
    FROM AdoptionRequest ar
    WHERE ar.adopter_id = a.adopter_id
      AND ar.status = 'Completed'
);

-- 8. Advanced: Pets whose shelter is operating above 50% capacity
SELECT
    s.shelter_id,
    s.name                                     AS shelter,
    s.capacity,
    COUNT(p.pet_id)                            AS current_pets,
    ROUND(COUNT(p.pet_id) / s.capacity * 100, 1) AS occupancy_pct
FROM Shelter s
LEFT JOIN Pet p ON p.shelter_id = s.shelter_id
              AND p.status NOT IN ('Adopted')
GROUP BY s.shelter_id, s.name, s.capacity
HAVING occupancy_pct > 50
ORDER BY occupancy_pct DESC;

-- ============================================================
-- REPORT 1: Adoption Statistics by Species
-- Business value: Management can see which species are most
-- requested and which have the longest wait times.
-- ============================================================
SELECT
    p.species,
    COUNT(p.pet_id)                                            AS total_pets,
    SUM(p.status = 'Available')                                AS available,
    SUM(p.status = 'Pending')                                  AS pending,
    SUM(p.status = 'Adopted')                                  AS adopted,
    SUM(p.status = 'Quarantine')                               AS quarantine,
    ROUND(SUM(p.status = 'Adopted') / COUNT(p.pet_id) * 100,1) AS adoption_rate_pct
FROM Pet p
GROUP BY p.species
ORDER BY total_pets DESC;

-- ============================================================
-- REPORT 2: Shelter Occupancy & Medical Activity
-- Business value: Operations team can identify overloaded shelters
-- and those with high medical needs requiring extra resources.
-- ============================================================
SELECT
    s.shelter_id,
    s.name                                           AS shelter_name,
    s.capacity,
    COUNT(DISTINCT p.pet_id)                         AS total_pets,
    ROUND(COUNT(DISTINCT p.pet_id)/s.capacity*100,1) AS occupancy_pct,
    COUNT(DISTINCT mr.record_id)                     AS total_medical_records,
    SUM(mr.vaccinated)                               AS vaccinations_given,
    COUNT(DISTINCT CASE WHEN mr.vaccinated = 1 THEN mr.pet_id END) AS fully_vaccinated_pets
FROM Shelter s
LEFT JOIN Pet           p  ON p.shelter_id  = s.shelter_id
LEFT JOIN MedicalRecord mr ON mr.pet_id     = p.pet_id
GROUP BY s.shelter_id, s.name, s.capacity
ORDER BY occupancy_pct DESC;

-- ============================================================
-- REPORT 3: Adopter Profile & Request Success Summary
-- Business value: Helps staff identify which housing types or
-- demographics lead to successful, completed adoptions, and
-- spot patterns in rejections.
-- ============================================================
SELECT
    a.housing_type,
    a.has_yard,
    a.has_children,
    COUNT(DISTINCT a.adopter_id)                         AS total_adopters,
    COUNT(ar.request_id)                                 AS total_requests,
    SUM(ar.status = 'Completed')                         AS completed,
    SUM(ar.status = 'Approved')                          AS approved,
    SUM(ar.status = 'Pending')                           AS pending,
    SUM(ar.status = 'Rejected')                          AS rejected,
    ROUND(SUM(ar.status = 'Completed')/COUNT(ar.request_id)*100,1) AS success_rate_pct,
    ROUND(AVG(DATEDIFF(ar.approval_date, ar.request_date)),1)       AS avg_days_to_approval
FROM Adopter a
LEFT JOIN AdoptionRequest ar ON ar.adopter_id = a.adopter_id
GROUP BY a.housing_type, a.has_yard, a.has_children
ORDER BY success_rate_pct DESC, total_requests DESC;
