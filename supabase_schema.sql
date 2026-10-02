-- CAMPUS360 SUPABASE DATABASE SCHEMA & INITIAL SEED DATA
-- Database: PostgreSQL (Supabase)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. STUDENTS TABLE
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    register_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(250) NOT NULL,
    college VARCHAR(250) NOT NULL DEFAULT 'OASYS Institute of Technology',
    department VARCHAR(250) NOT NULL DEFAULT 'B.Tech - Artificial Intelligence and Data Science',
    year VARCHAR(50) NOT NULL DEFAULT 'III Year',
    semester VARCHAR(50) NOT NULL DEFAULT 'V Semester',
    password VARCHAR(250) NOT NULL DEFAULT 'passoasys',
    profile_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. ADMIN USERS TABLE
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(250) NOT NULL,
    name VARCHAR(250) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. STAFF TABLE
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(250) NOT NULL,
    role_title VARCHAR(150) NOT NULL,
    department VARCHAR(250) NOT NULL DEFAULT 'Artificial Intelligence and Data Science',
    status VARCHAR(50) NOT NULL DEFAULT 'Present',
    assigned_alternative VARCHAR(250) DEFAULT 'None',
    phone VARCHAR(50),
    email VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(250) NOT NULL,
    message TEXT NOT NULL,
    recipient_type VARCHAR(50) NOT NULL DEFAULT 'broadcast', -- 'admin', 'student', 'broadcast'
    recipient_id VARCHAR(100) NOT NULL DEFAULT 'all', -- 'admin', register_number, or 'all'
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 5. COMPLAINTS TABLE
CREATE TABLE IF NOT EXISTS public.complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_name VARCHAR(250) NOT NULL,
    register_number VARCHAR(50) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subject VARCHAR(250) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- 'Pending', 'In Progress', 'Resolved', 'Rejected'
    admin_response TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 6. LOST & FOUND TABLE
CREATE TABLE IF NOT EXISTS public.lost_found (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL, -- 'lost' or 'found'
    title VARCHAR(250) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(250) NOT NULL,
    date VARCHAR(50) NOT NULL,
    image_url TEXT,
    student_name VARCHAR(250) NOT NULL,
    register_number VARCHAR(50) NOT NULL,
    department VARCHAR(250) NOT NULL,
    contact_phone VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'Open', -- 'Open', 'Resolved'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 7. FOOD TABLE
CREATE TABLE IF NOT EXISTS public.food (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    menu_items TEXT NOT NULL,
    total_meals INT NOT NULL DEFAULT 500,
    servable_students INT NOT NULL DEFAULT 500,
    remaining_meals INT NOT NULL DEFAULT 350,
    status VARCHAR(100) NOT NULL DEFAULT 'Available',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 8. TOKENS TABLE
CREATE TABLE IF NOT EXISTS public.tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    queue_type VARCHAR(20) NOT NULL, -- 'OFF', 'CAN', 'LIB'
    token_number INT NOT NULL,
    student_name VARCHAR(250) NOT NULL,
    register_number VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Waiting', -- 'Waiting', 'Serving', 'Completed', 'Skipped'
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    called_at TIMESTAMP WITH TIME ZONE
);

-- 9. TIMETABLE TABLE
CREATE TABLE IF NOT EXISTS public.timetable (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day VARCHAR(20) NOT NULL, -- 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
    period_num INT NOT NULL, -- 1 to 8
    time_slot VARCHAR(50) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    subject_name VARCHAR(250) NOT NULL,
    faculty_name VARCHAR(250) NOT NULL,
    room VARCHAR(50) DEFAULT 'LH-302',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 10. STUDENT ATTENDANCE TABLE
CREATE TABLE IF NOT EXISTS public.student_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    register_number VARCHAR(50) NOT NULL,
    student_name VARCHAR(250) NOT NULL,
    subject_code VARCHAR(50) NOT NULL DEFAULT 'GENERAL',
    period_num INT NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'Present', -- 'Present', 'Absent'
    marked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    UNIQUE(date, register_number, period_num)
);

-- 11. STAFF ATTENDANCE TABLE
CREATE TABLE IF NOT EXISTS public.staff_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    staff_id UUID REFERENCES public.staff(id) ON DELETE CASCADE,
    staff_name VARCHAR(250) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Present',
    assigned_alternative VARCHAR(250) DEFAULT 'None',
    marked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- SEED DATA INSERTION

-- Seed Admin
INSERT INTO public.admin_users (username, password, name)
VALUES ('Rajesh', 'nira31', 'Rajesh (Administrator)')
ON CONFLICT (username) DO NOTHING;

-- Seed All 51 Students
INSERT INTO public.students (register_number, name, college, department, year, semester, password) VALUES
('812924243001', 'AKSHITHA E', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243002', 'ARAVINTH A', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243003', 'ARJUNAN M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243004', 'ARYA R', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243005', 'ASWIN KUMAR M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243006', 'AYYAPPAN V', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243007', 'DEVANATHAN D', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243008', 'DHARUN V', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243009', 'DHAYANITHI K', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243010', 'DHINESHKUMAR T', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243011', 'DIVYAVENI N', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243012', 'GOBIKA S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243013', 'GOPALAKRISHNAN T', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243014', 'HARIKARAN D', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243015', 'HARIKRISHNAN C', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243016', 'HARINI G', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243017', 'HEMAMALINI S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243018', 'JAFFER SHATHICK N', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243019', 'JAISURYA M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243020', 'JANISHA S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243021', 'KUMARESAN V', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243022', 'LENIN K', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243023', 'MAHENDRAN M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243024', 'MOHAMED FAJIR M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243025', 'MUGESH V', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243026', 'NAVEEN R', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243027', 'NITHEESH N', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243028', 'PAVITHRA P', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243029', 'PERIYADURAI E', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243030', 'PERIYAR SELVAN A', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243031', 'RAHUL W', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243032', 'RAHINI S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243033', 'RAJESH B', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243034', 'STUDENT 34', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243035', 'RANJITH M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243036', 'SABITHRA J', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243037', 'SAGANA S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243038', 'SANMUGESHWAR S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243039', 'SANTHOSH RAJU K', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243040', 'SARVESHWARAN M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243041', 'SEENIVASAN R', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243042', 'SRIDHAR P', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243043', 'SUDHARSON A', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243044', 'SURESH S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243045', 'SWETHA S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243046', 'VAIGUNTH R', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243047', 'VIDYA BALAN M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243048', 'VIGNESH R', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243049', 'VIMAL S', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243050', 'VINNARASI V', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys'),
('812924243051', 'KEERTHIKA M', 'OASYS Institute of Technology', 'B.Tech - Artificial Intelligence and Data Science', 'III Year', 'V Semester', 'passoasys')
ON CONFLICT (register_number) DO NOTHING;

-- Seed Staff
INSERT INTO public.staff (name, role_title, department, status) VALUES
('Ms M. Punitha', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mr G. Devanavan', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mr N. Sabarivasan', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mrs P. Bharathi', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mrs N. Gomathy', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mrs V. Kayalvizhi', 'Assistant Professor', 'Artificial Intelligence and Data Science', 'Present'),
('Mr S. Sivaraj', 'Assistant Professor', 'Electronics & Communication Engineering', 'Present'),
('Ms Mahalakshmi', 'Technical Trainer', 'TNSDC Skill Development', 'Present');

-- Seed Food Initial State
INSERT INTO public.food (menu_items, total_meals, servable_students, remaining_meals, status)
VALUES ('South Indian Thali: Rice, Sambar, Rasam, Poriyal, Curd, Appalam, Veg Curry', 500, 500, 320, 'Available');

-- Enable Realtime Subscriptions in Supabase
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.complaints;
ALTER PUBLICATION supabase_realtime ADD TABLE public.lost_found;
ALTER PUBLICATION supabase_realtime ADD TABLE public.food;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tokens;
ALTER PUBLICATION supabase_realtime ADD TABLE public.student_attendance;
ALTER PUBLICATION supabase_realtime ADD TABLE public.staff_attendance;
