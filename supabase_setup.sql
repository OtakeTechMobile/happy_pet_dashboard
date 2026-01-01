-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== TABLES ====================

-- Hotels table
CREATE TABLE IF NOT EXISTS hotels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address_street TEXT,
    address_number TEXT,
    address_city TEXT,
    address_state TEXT,
    address_zip TEXT,
    phone TEXT,
    email TEXT,
    capacity INTEGER DEFAULT 20,
    max_staff INTEGER DEFAULT 3,
    business_hours JSONB DEFAULT '{}'::jsonb,
    settings JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure hotels table has max_staff (if it existed before)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hotels' AND column_name='max_staff') THEN
        ALTER TABLE hotels ADD COLUMN max_staff INTEGER DEFAULT 3;
    END IF;
END $$;

-- Tutors (Clients)
CREATE TABLE IF NOT EXISTS tutors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hotel_id UUID REFERENCES hotels(id) ON DELETE SET NULL,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    secondary_phone TEXT,
    cpf TEXT,
    address_street TEXT,
    address_number TEXT,
    address_complement TEXT,
    address_neighborhood TEXT,
    address_city TEXT,
    address_state TEXT,
    address_zip TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    notes TEXT,
    documents JSONB DEFAULT '[]'::jsonb,
    withdrawal_authorizations JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure tutors table has hotel_id and withdrawal_authorizations
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tutors' AND column_name='hotel_id') THEN
        ALTER TABLE tutors ADD COLUMN hotel_id UUID REFERENCES hotels(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tutors' AND column_name='withdrawal_authorizations') THEN
        ALTER TABLE tutors ADD COLUMN withdrawal_authorizations JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- Pets
CREATE TABLE IF NOT EXISTS pets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tutor_id UUID REFERENCES tutors(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES hotels(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT,
    gender TEXT,
    birth_date DATE,
    weight NUMERIC,
    microchip_number TEXT,
    color TEXT,
    photo_url TEXT,
    photos TEXT[] DEFAULT '{}',
    medical_conditions TEXT,
    allergies TEXT,
    special_needs TEXT,
    food_brand TEXT,
    food_amount TEXT,
    feeding_times INTEGER DEFAULT 2,
    vaccinations JSONB DEFAULT '[]'::jsonb,
    medications JSONB DEFAULT '[]'::jsonb,
    veterinarian_name TEXT,
    veterinarian_phone TEXT,
    behavioral_assessment TEXT,
    exercise_needs TEXT,
    diet_restrictions TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure pets table has hotel_id and behavioral assessment fields
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pets' AND column_name='hotel_id') THEN
        ALTER TABLE pets ADD COLUMN hotel_id UUID REFERENCES hotels(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pets' AND column_name='behavioral_assessment') THEN
        ALTER TABLE pets ADD COLUMN behavioral_assessment TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pets' AND column_name='exercise_needs') THEN
        ALTER TABLE pets ADD COLUMN exercise_needs TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pets' AND column_name='diet_restrictions') THEN
        ALTER TABLE pets ADD COLUMN diet_restrictions TEXT;
    END IF;
END $$;

-- Daily Logs (for Pátio module)
CREATE TABLE IF NOT EXISTS daily_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- feeding, activity, incident, notes
    title TEXT NOT NULL,
    description TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stays
CREATE TABLE IF NOT EXISTS stays (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
    tutor_id UUID REFERENCES tutors(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE,
    status TEXT NOT NULL, -- scheduled, checked_in, checked_out, cancelled
    scheduled_checkin TIMESTAMPTZ NOT NULL,
    scheduled_checkout TIMESTAMPTZ NOT NULL,
    actual_checkin TIMESTAMPTZ,
    actual_checkout TIMESTAMPTZ,
    check_in_by UUID,
    check_out_by UUID,
    package_type TEXT,
    base_price NUMERIC,
    additional_services JSONB DEFAULT '[]'::jsonb,
    total_price NUMERIC,
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMPTZ,
    cancelled_by UUID,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure stays table has hotel_id
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='stays' AND column_name='hotel_id') THEN
        ALTER TABLE stays ADD COLUMN hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Routines (Appointments/Activities)
CREATE TABLE IF NOT EXISTS routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stay_id UUID,
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- feeding, medication, exercise, grooming, other
    title TEXT NOT NULL,
    description TEXT,
    scheduled_time TEXT NOT NULL, -- HH:mm
    date DATE NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, in_progress, completed, skipped
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    assigned_to UUID,
    completed_by UUID,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure routines table has hotel_id
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='routines' AND column_name='hotel_id') THEN
        ALTER TABLE routines ADD COLUMN hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ==================== SEED DATA ====================

-- Need to insert a default hotel for seed data if needed
INSERT INTO hotels (id, name) VALUES ('00000000-0000-0000-0000-000000000000', 'Happy Pet Matriz') ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    i INT;
    tutor_id UUID;
    pet_id UUID;
    h_id UUID := '00000000-0000-0000-0000-000000000000';
    status TEXT;
    is_active BOOLEAN;
    appointment_status TEXT;
    service_type TEXT;
BEGIN
    -- Insert 5 Tutors for testing if table is empty
    IF NOT EXISTS (SELECT 1 FROM tutors LIMIT 1) THEN
        FOR i IN 1..5 LOOP
            INSERT INTO tutors (hotel_id, full_name, email, phone, is_active, created_at, updated_at)
            VALUES (
                h_id,
                'Client ' || i,
                'client' || i || '@example.com',
                '(11) 99999-' || (1000 + i),
                true,
                NOW(),
                NOW()
            );
        END LOOP;
    END IF;

END $$;
