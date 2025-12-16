-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== TABLES ====================

-- Tutors (Clients)
CREATE TABLE IF NOT EXISTS tutors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pets
CREATE TABLE IF NOT EXISTS pets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tutor_id UUID REFERENCES tutors(id) ON DELETE CASCADE,
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
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stays (Optional for now, but needed for foreign key if enforced)
CREATE TABLE IF NOT EXISTS stays (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
    tutor_id UUID REFERENCES tutors(id) ON DELETE CASCADE,
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

-- Routines (Appointments/Activities)
CREATE TABLE IF NOT EXISTS routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stay_id UUID, -- Can be null for standalone appointments
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
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


-- ==================== SEED DATA ====================

DO $$
DECLARE
    i INT;
    tutor_id UUID;
    pet_id UUID;
    status TEXT;
    is_active BOOLEAN;
    appointment_status TEXT;
    service_type TEXT;
BEGIN
    -- Insert 50 Tutors
    FOR i IN 1..50 LOOP
        IF i % 4 = 0 THEN
            is_active := false;
        ELSE
            is_active := true;
        END IF;

        INSERT INTO tutors (full_name, email, phone, is_active, created_at, updated_at)
        VALUES (
            'Client ' || i,
            'client' || i || '@example.com',
            '(11) 99999-' || (1000 + i),
            is_active,
            NOW(),
            NOW()
        );
    END LOOP;

    -- Insert 25 Pets (linking to random tutors)
    FOR i IN 1..25 LOOP
        -- Select a random tutor
        SELECT id INTO tutor_id FROM tutors ORDER BY random() LIMIT 1;
        
        IF i % 3 = 0 THEN
             -- "Checkup Due" simulation logic (handled by logic, but here we just insert basic data)
             -- We can simulatesome expired vaccination if we want, but keeping it simple.
             NULL; 
        END IF;

        INSERT INTO pets (
            tutor_id, 
            name, 
            species, 
            breed, 
            birth_date, 
            photo_url, 
            is_active
        )
        VALUES (
            tutor_id,
            'Doggo ' || i,
            'Dog',
            'Golden Retriever',
            CURRENT_DATE - (i + 2 || ' years')::INTERVAL,
            'https://placedog.net/100/100?id=' || i,
            true
        );
    END LOOP;

    -- Insert 8 Appointments (Routines)
    FOR i IN 1..8 LOOP
        -- Select a random pet
        SELECT id INTO pet_id FROM pets ORDER BY random() LIMIT 1;
        
        IF i % 2 = 0 THEN
            service_type := 'grooming';
        ELSE
            service_type := 'other'; -- Checkup is not in enum, using 'other' with title 'Checkup'
        END IF;

        IF i <= 2 THEN
            appointment_status := 'completed';
        ELSE
            appointment_status := 'pending'; -- 'Scheduled' maps to pending
        END IF;

        INSERT INTO routines (
            pet_id,
            type,
            title,
            scheduled_time,
            date,
            status
        )
        VALUES (
            pet_id,
            service_type,
            CASE WHEN i % 2 = 0 THEN 'Grooming' ELSE 'Checkup' END,
            TO_CHAR(NOW() + (i || ' hours')::INTERVAL, 'HH24:MI'),
            CURRENT_DATE,
            appointment_status
        );
    END LOOP;

END $$;
