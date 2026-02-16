-- PostgreSQL CREATE TABLE scripts with IF NOT EXISTS
-- Using GENERATED ALWAYS AS IDENTITY for primary keys

CREATE TABLE IF NOT EXISTS hospitals (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    pincode VARCHAR(10),
    abha_facility_id VARCHAR(64),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS departments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id BIGINT NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    specialty_model VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE,
    phone VARCHAR(20),
    gender VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS doctors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id BIGINT NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
    abha_professional_id VARCHAR(64),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    license_number VARCHAR(50),
    specialty VARCHAR(100),
    custom_vocab JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    userid BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    photo BYTEA
);

CREATE TABLE IF NOT EXISTS patients (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id BIGINT REFERENCES hospitals(id) ON DELETE SET NULL,
    external_id VARCHAR(64),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    sex VARCHAR(10),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS encounters (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id BIGINT NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    patient_id BIGINT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    doctor_id BIGINT REFERENCES doctors(id) ON DELETE SET NULL,
    external_id VARCHAR(64),
    encounter_type VARCHAR(50),
    department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dictations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id BIGINT NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    department_id BIGINT NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    doctor_id BIGINT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id BIGINT REFERENCES patients(id) ON DELETE SET NULL,
    encounter_id BIGINT REFERENCES encounters(id) ON DELETE SET NULL,
    dictation_number VARCHAR(50) UNIQUE,
    language VARCHAR(10) DEFAULT 'en-IN',
    status VARCHAR(20) NOT NULL,
    audio_path TEXT,
    duration_sec INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transcriptions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dictation_id BIGINT NOT NULL REFERENCES dictations(id) ON DELETE CASCADE,
    doctor_id BIGINT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    raw_text TEXT NOT NULL,
    model_name VARCHAR(100),
    confidence NUMERIC(4,3),
    word_count INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS snomed_annotations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dictation_id BIGINT NOT NULL REFERENCES dictations(id) ON DELETE CASCADE,
    doctor_id BIGINT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    transcription_id BIGINT REFERENCES transcriptions(id) ON DELETE SET NULL,
    snomed_concept_id BIGINT NOT NULL,
    term TEXT NOT NULL,
    category VARCHAR(50),
    start_char INTEGER,
    end_char INTEGER,
    confidence NUMERIC(4,3),
    model_used VARCHAR(50),
    extra JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS clinical_documents (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dictation_id BIGINT NOT NULL REFERENCES dictations(id) ON DELETE CASCADE,
    hospital_id BIGINT NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    department_id BIGINT NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    doctor_id BIGINT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id BIGINT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    encounter_id BIGINT REFERENCES encounters(id) ON DELETE SET NULL,
    document_type VARCHAR(50),
    version INTEGER DEFAULT 1,
    status VARCHAR(20) NOT NULL,
    final_text TEXT NOT NULL,
    fhir_resource_type VARCHAR(50),
    fhir_json JSONB,
    doctor_signature TEXT,
    signed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
