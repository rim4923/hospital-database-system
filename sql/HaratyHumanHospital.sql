-- Drop tables if they exist for a clean setup (check your SQL environment syntax if DROP IF EXISTS is not supported)
--DROP TABLE IF EXISTS TREATS CASCADE;
--DROP TABLE IF EXISTS USES CASCADE;
--DROP TABLE IF EXISTS PATIENT_ALLERGIES CASCADE;
--DROP TABLE IF EXISTS PATIENT_DIAGNOSIS_HISTORY CASCADE;
--DROP TABLE IF EXISTS DR_SUBSPECIALTIES CASCADE;
--DROP TABLE IF EXISTS INSURANCE CASCADE;
--DROP TABLE IF EXISTS BLOOD_BANK CASCADE;
--DROP TABLE IF EXISTS SERVICE CASCADE;
--DROP TABLE IF EXISTS PATIENT CASCADE;
--DROP TABLE IF EXISTS MEDICAL_RECORD CASCADE;
--DROP TABLE IF EXISTS DOCTOR CASCADE;
--DROP TABLE IF EXISTS STAFF CASCADE;
--DROP TABLE IF EXISTS ROOM CASCADE;
--DROP TABLE IF EXISTS INVENTORY CASCADE;
--DROP TABLE IF EXISTS SUPPLIER CASCADE;
--DROP TABLE IF EXISTS AMBULANCE CASCADE;
--DROP TABLE IF EXISTS DEPARTMENT CASCADE;

-- Create DEPARTMENT table
CREATE TABLE DEPARTMENT (
    Dept_ID VARCHAR(3) PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Ext NUMBER(3),
    Email VARCHAR(100) NOT NULL,
    CHECK (REGEXP_LIKE(Email, '^[^@]+@[^@]+\.[^@]+$')),
    Bldg_Nb VARCHAR(2) NOT NULL
);

-- Create AMBULANCE table
CREATE TABLE AMBULANCE (
    License_Plate CHAR(10) PRIMARY KEY,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Available', 'In Use', 'Under Maintenance')),
    Model CHAR(4) NOT NULL,
    Last_Check DATE
);

-- Create SUPPLIER table
CREATE TABLE SUPPLIER (
    Supp_ID CHAR(9) PRIMARY KEY,
    Supp_Name VARCHAR(50) NOT NULL,
    Phone_Nb CHAR(10) NOT NULL CHECK (Phone_Nb LIKE ''),
    Email VARCHAR(100) CHECK (REGEXP_LIKE(Email, '^[^@]+@[^@]+\.[^@]+$')),
    Terms VARCHAR(500),
    Expiry_Date DATE
);

-- Create STAFF table
CREATE TABLE STAFF (
    ID CHAR(9) PRIMARY KEY,
    First VARCHAR(30) NOT NULL,
    MI CHAR(1),
    Last VARCHAR(30) NOT NULL,
    DOB DATE,
    SSN CHAR(9) NOT NULL,
    Address VARCHAR(50) NOT NULL,
    Emergency_Name VARCHAR(30) NOT NULL,
    Rel VARCHAR(20) NOT NULL,
    Phone_Nb CHAR(10) NOT NULL,
    Position VARCHAR(30) NOT NULL,
    Hiring_Date DATE,
    Emp_Type CHAR(9) CHECK (Emp_Type IN ('Full Time', 'Part Time')),
    Weekly_Hours NUMBER(2),
    Hourly_Rate NUMBER(5,2),
    Vacations_Per_Year NUMBER(3),
    End_Date DATE,
    Dept_ID VARCHAR(3),
    License_Plate CHAR(10),
    FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Dept_ID),
    FOREIGN KEY (License_Plate) REFERENCES AMBULANCE (License_Plate)
);

-- Create DOCTOR table
CREATE TABLE DOCTOR(
    D_ID CHAR(9) PRIMARY KEY,
    License_Nb CHAR(9) NOT NULL,
    Specialty VARCHAR(100),
    Salary NUMBER(10,2),
    Bldg_Nb VARCHAR(2) NOT NULL,
    Office_Nb CHAR(3),
    Availability CHAR(1) CHECK (Availability IN('Y', 'N')),
    Paging_Nb CHAR(4),
    Staff_ID CHAR(9),
    FOREIGN KEY (Staff_ID) REFERENCES STAFF(ID)
);

-- Create ROOM table
CREATE TABLE ROOM(
    Bldg_Nb VARCHAR(2),
    Room_Nb VARCHAR(3),
    Type VARCHAR(20),
    Capacity NUMBER(2),
    Status VARCHAR(20) CHECK(Status IN ('Available', 'Occupied', 'Under Maintenance', 'Cleaning Required')),
    PRIMARY KEY (Bldg_Nb, Room_Nb)
);

-- Create MEDICAL_RECORD table
CREATE TABLE MEDICAL_RECORD (
    Record_ID CHAR(9) PRIMARY KEY,
    Patient_ID CHAR(9) NOT NULL,
    Blood_Type CHAR(3) CHECK (Blood_Type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Weight NUMERIC(5, 2) CHECK (Weight > 0 AND Weight <= 700),
    Height NUMERIC(4, 2) CHECK (Height > 0 AND Height <= 3),
    FOREIGN KEY (Patient_ID) REFERENCES STAFF (ID) -- Assuming patients are also staff for this setup
);

-- Create PATIENT table
CREATE TABLE PATIENT (
    Patient_ID CHAR(9) PRIMARY KEY,
    First VARCHAR(30) NOT NULL,
    MI CHAR(1),
    Last VARCHAR(30) NOT NULL,
    Sex CHAR(1) CHECK (Sex IN ('F', 'M', 'I')),
    DOB DATE,
    Address VARCHAR(50) NOT NULL,
    Phone_Nb CHAR(10) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    CHECK (REGEXP_LIKE(Email, '^[^@]+@[^@]+\.[^@]+$')),
    E_Name VARCHAR(30) NOT NULL,
    E_Rel VARCHAR(30) NOT NULL,
    E_Phone_Nb CHAR(10) NOT NULL,
    Record_ID CHAR(9),
    FOREIGN KEY (Record_ID) REFERENCES MEDICAL_RECORD(Record_ID)
);

-- Create SERVICE table
CREATE TABLE SERVICE(
    Service_ID CHAR(9) PRIMARY KEY,
    Type VARCHAR(40) NOT NULL,
    Date DATE,
    Result VARCHAR(255),
    D_ID CHAR(9), -- Foreign Key to Doctor ID if services are provided by doctors
    FOREIGN KEY (D_ID) REFERENCES DOCTOR(D_ID)
);

-- Create BLOOD_BANK table
CREATE TABLE BLOOD_BANK (
    Donation_ID CHAR(9) PRIMARY KEY,
    Blood_Type CHAR(3) CHECK (Blood_Type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    First VARCHAR(30) NOT NULL,
    MI CHAR(1),
    Last VARCHAR(30) NOT NULL,
    Phone_Nb CHAR(10) NOT NULL CHECK (Phone_Nb LIKE ''),
    Collection_Date DATE NOT NULL,
    Availability CHAR(1) CHECK (Availability IN ('Y', 'N')),
    Service_ID CHAR(9),
    FOREIGN KEY (Service_ID) REFERENCES SERVICE(Service_ID)
);

-- Create INVENTORY table
CREATE TABLE INVENTORY (
    Item_Name VARCHAR(50) NOT NULL,
    Batch_ID CHAR(9) PRIMARY KEY,
    Qty NUMBER(6) NOT NULL CHECK (Qty >= 0),
    Expiry_Date DATE NOT NULL,
    Reorder_Threshold NUMBER(6) NOT_NULL CHECK (Reorder_Threshold >= 0),
    Supp_ID CHAR(9),
    Batch_Rating NUMBER(2, 1) CHECK (Batch_Rating BETWEEN 0 AND 5),
    FOREIGN KEY (Supp_ID) REFERENCES SUPPLIER(Supp_ID)
);

-- Create INSURANCE table
CREATE TABLE INSURANCE (
    Insurance_ID CHAR(9) PRIMARY KEY,
    First VARCHAR(30) NOT NULL,
    MI CHAR(1),
    Last VARCHAR(30) NOT NULL,
    Policy_Nb VARCHAR(11) NOT NULL CHECK (REGEXP_LIKE(Policy_Nb, '^[A-Z]{2}-[0-9]{8}$')),
    Coverage_Type VARCHAR(7) CHECK (Coverage_Type IN ('class A', 'class B', 'class C')),
    P_Name VARCHAR(30) NOT NULL,
    Phone_Nb CHAR(10) NOT_NULL CHECK (Phone_Nb LIKE ''),
    Email VARCHAR(100) CHECK (REGEXP_LIKE(Email, '^[^@]+@[^@]+\.[^@]+$')),
    Start_Date DATE NOT NULL,
    End_Date DATE,
    Patient_ID CHAR(9),
    FOREIGN KEY (Patient_ID) REFERENCES PATIENT(Patient_ID)
);

-- Relationship tables
CREATE TABLE DR_SUBSPECIALTIES (
    Doctor_ID CHAR(9),
    Subspecialties VARCHAR(200),
    PRIMARY KEY (Doctor_ID, Subspecialties),
    FOREIGN KEY (Doctor_ID) REFERENCES DOCTOR(D_ID)
);

CREATE TABLE TREATS (
    Patient_ID CHAR(9),
    Doctor_ID CHAR(9),
    PRIMARY KEY (Patient_ID, Doctor_ID),
    FOREIGN KEY (Patient_ID) REFERENCES PATIENT(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES DOCTOR(D_ID)
);

CREATE TABLE USES (
    Service_ID CHAR(9),
    Item_Name VARCHAR(50),
    PRIMARY KEY (Service_ID, Item_Name),
    FOREIGN KEY (Service_ID) REFERENCES SERVICE(Service_ID),
    FOREIGN KEY (Item_Name) REFERENCES INVENTORY(Item_Name)
);

CREATE TABLE PATIENT_ALLERGIES (
    Record_ID CHAR(9),
    PAllergies VARCHAR(100),
    PRIMARY KEY (Record_ID, PAllergies),
    FOREIGN KEY (Record_ID) REFERENCES MEDICAL_RECORD(Record_ID)
);

CREATE TABLE PATIENT_DIAGNOSIS_HISTORY (
    Record_ID CHAR(9),
    Diagnosis_History VARCHAR(100),
    PRIMARY KEY (Record_ID, Diagnosis_History),
    FOREIGN KEY (Record_ID) REFERENCES MEDICAL_RECORD(Record_ID)
);