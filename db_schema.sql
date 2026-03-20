-- ============================================================
--  EduMetrics — Client Database (Week 0)
--  3 classes: BTech CSE Sem 1, Sem 3, Sem 5
--  40 students per class
--  Run in MySQL Workbench on edumetrics_client schema
-- ============================================================


CREATE DATABASE IF NOT EXISTS edumetrics_client
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE edumetrics_client;

-- ── 1. CLASSES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS classes (
  class_id        VARCHAR(20)  PRIMARY KEY,
  name            VARCHAR(60)  NOT NULL,
  semester        INT          NOT NULL,
  year_of_study   INT          NOT NULL,
  section         VARCHAR(5)   DEFAULT 'A',
  branch          VARCHAR(20)  DEFAULT 'CSE',
  batch_start_year INT,
  academic_year   VARCHAR(12),
  total_students  INT
);

INSERT INTO classes VALUES
  ('CSE_SEM1_A', 'BTech CSE Sem 1 Section A', 1, 1, 'A', 'CSE', 2024, '2024-25', 40),
  ('CSE_SEM3_A', 'BTech CSE Sem 3 Section A', 3, 2, 'A', 'CSE', 2023, '2024-25', 40),
  ('CSE_SEM5_A', 'BTech CSE Sem 5 Section A', 5, 3, 'A', 'CSE', 2022, '2024-25', 40);

-- ── 2. ADVISORS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS advisors (
  advisor_id      VARCHAR(10)  PRIMARY KEY,
  name            VARCHAR(80)  NOT NULL,
  email           VARCHAR(100) UNIQUE NOT NULL,
  class_id        VARCHAR(20),
  FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

INSERT INTO advisors VALUES
  ('ADV001', 'Dr. Priya Mehta',   'priya.mehta@college.edu',   'CSE_SEM1_A'),
  ('ADV002', 'Dr. Rohan Sharma',  'rohan.sharma@college.edu',  'CSE_SEM3_A'),
  ('ADV003', 'Dr. Sunita Nair',   'sunita.nair@college.edu',   'CSE_SEM5_A');

-- ── 3. STUDENTS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
  student_id      VARCHAR(10)  PRIMARY KEY,
  class_id        VARCHAR(20)  NOT NULL,
  advisor_id      VARCHAR(10),
  name            VARCHAR(80)  NOT NULL,
  roll_number     INT          NOT NULL,
  gender          CHAR(1),
  email           VARCHAR(100) UNIQUE,
  parent_email    VARCHAR(100),
  phone           VARCHAR(15),
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (advisor_id) REFERENCES advisors(advisor_id)
);

-- Sem 1 students (STU001–STU040)
INSERT INTO students (student_id,class_id,advisor_id,name,roll_number,gender,email,parent_email) VALUES
('STU001','CSE_SEM1_A','ADV001','Aarav Kumar',1,'M','aarav.kumar@college.edu','parent.aarav@gmail.com'),
('STU002','CSE_SEM1_A','ADV001','Vivaan Sharma',2,'M','vivaan.sharma@college.edu','parent.vivaan@gmail.com'),
('STU003','CSE_SEM1_A','ADV001','Aditya Singh',3,'M','aditya.singh@college.edu','parent.aditya@gmail.com'),
('STU004','CSE_SEM1_A','ADV001','Ananya Patel',4,'F','ananya.patel@college.edu','parent.ananya@gmail.com'),
('STU005','CSE_SEM1_A','ADV001','Diya Gupta',5,'F','diya.gupta@college.edu','parent.diya@gmail.com'),
('STU006','CSE_SEM1_A','ADV001','Priya Joshi',6,'F','priya.joshi@college.edu','parent.priya@gmail.com'),
('STU007','CSE_SEM1_A','ADV001','Rahul Verma',7,'M','rahul.verma@college.edu','parent.rahul@gmail.com'),
('STU008','CSE_SEM1_A','ADV001','Rohan Mishra',8,'M','rohan.mishra@college.edu','parent.rohan@gmail.com'),
('STU009','CSE_SEM1_A','ADV001','Sneha Rao',9,'F','sneha.rao@college.edu','parent.sneha@gmail.com'),
('STU010','CSE_SEM1_A','ADV001','Kiran Reddy',10,'M','kiran.reddy@college.edu','parent.kiran@gmail.com'),
('STU011','CSE_SEM1_A','ADV001','Meera Nair',11,'F','meera.nair@college.edu','parent.meera@gmail.com'),
('STU012','CSE_SEM1_A','ADV001','Ishaan Pillai',12,'M','ishaan.pillai@college.edu','parent.ishaan@gmail.com'),
('STU013','CSE_SEM1_A','ADV001','Tanvi Shah',13,'F','tanvi.shah@college.edu','parent.tanvi@gmail.com'),
('STU014','CSE_SEM1_A','ADV001','Yash Mehta',14,'M','yash.mehta@college.edu','parent.yash@gmail.com'),
('STU015','CSE_SEM1_A','ADV001','Sakshi Chopra',15,'F','sakshi.chopra@college.edu','parent.sakshi@gmail.com'),
('STU016','CSE_SEM1_A','ADV001','Dev Bose',16,'M','dev.bose@college.edu','parent.dev@gmail.com'),
('STU017','CSE_SEM1_A','ADV001','Aryan Das',17,'M','aryan.das@college.edu','parent.aryan@gmail.com'),
('STU018','CSE_SEM1_A','ADV001','Kavya Iyer',18,'F','kavya.iyer@college.edu','parent.kavya@gmail.com'),
('STU019','CSE_SEM1_A','ADV001','Simran Menon',19,'F','simran.menon@college.edu','parent.simran@gmail.com'),
('STU020','CSE_SEM1_A','ADV001','Harsh Chandra',20,'M','harsh.chandra@college.edu','parent.harsh@gmail.com'),
('STU021','CSE_SEM1_A','ADV001','Neha Kumar',21,'F','neha.kumar@college.edu','parent.neha@gmail.com'),
('STU022','CSE_SEM1_A','ADV001','Ritesh Sharma',22,'M','ritesh.sharma@college.edu','parent.ritesh@gmail.com'),
('STU023','CSE_SEM1_A','ADV001','Divya Singh',23,'F','divya.singh@college.edu','parent.divya@gmail.com'),
('STU024','CSE_SEM1_A','ADV001','Nikhil Patel',24,'M','nikhil.patel@college.edu','parent.nikhil@gmail.com'),
('STU025','CSE_SEM1_A','ADV001','Shreya Gupta',25,'F','shreya.gupta@college.edu','parent.shreya@gmail.com'),
('STU026','CSE_SEM1_A','ADV001','Amit Joshi',26,'M','amit.joshi@college.edu','parent.amit@gmail.com'),
('STU027','CSE_SEM1_A','ADV001','Kajal Verma',27,'F','kajal.verma@college.edu','parent.kajal@gmail.com'),
('STU028','CSE_SEM1_A','ADV001','Ravi Mishra',28,'M','ravi.mishra@college.edu','parent.ravi@gmail.com'),
('STU029','CSE_SEM1_A','ADV001','Sunita Rao',29,'F','sunita.rao@college.edu','parent.sunita@gmail.com'),
('STU030','CSE_SEM1_A','ADV001','Manish Reddy',30,'M','manish.reddy@college.edu','parent.manish@gmail.com'),
('STU031','CSE_SEM1_A','ADV001','Pallavi Nair',31,'F','pallavi.nair@college.edu','parent.pallavi@gmail.com'),
('STU032','CSE_SEM1_A','ADV001','Gaurav Pillai',32,'M','gaurav.pillai@college.edu','parent.gaurav@gmail.com'),
('STU033','CSE_SEM1_A','ADV001','Swati Shah',33,'F','swati.shah@college.edu','parent.swati@gmail.com'),
('STU034','CSE_SEM1_A','ADV001','Deepak Mehta',34,'M','deepak.mehta@college.edu','parent.deepak@gmail.com'),
('STU035','CSE_SEM1_A','ADV001','Rekha Chopra',35,'F','rekha.chopra@college.edu','parent.rekha@gmail.com'),
('STU036','CSE_SEM1_A','ADV001','Sanjay Bose',36,'M','sanjay.bose@college.edu','parent.sanjay@gmail.com'),
('STU037','CSE_SEM1_A','ADV001','Ankita Das',37,'F','ankita.das@college.edu','parent.ankita@gmail.com'),
('STU038','CSE_SEM1_A','ADV001','Vikram Iyer',38,'M','vikram.iyer@college.edu','parent.vikram@gmail.com'),
('STU039','CSE_SEM1_A','ADV001','Preeti Menon',39,'F','preeti.menon@college.edu','parent.preeti@gmail.com'),
('STU040','CSE_SEM1_A','ADV001','Rajesh Chandra',40,'M','rajesh.chandra@college.edu','parent.rajesh@gmail.com');

-- Sem 3 students (STU041–STU080)
INSERT INTO students (student_id,class_id,advisor_id,name,roll_number,gender,email,parent_email) VALUES
('STU041','CSE_SEM3_A','ADV002','Tarun Kumar',1,'M','tarun.kumar@college.edu','parent.tarun@gmail.com'),
('STU042','CSE_SEM3_A','ADV002','Bhavna Sharma',2,'F','bhavna.sharma@college.edu','parent.bhavna@gmail.com'),
('STU043','CSE_SEM3_A','ADV002','Suresh Singh',3,'M','suresh.singh@college.edu','parent.suresh@gmail.com'),
('STU044','CSE_SEM3_A','ADV002','Geeta Patel',4,'F','geeta.patel@college.edu','parent.geeta@gmail.com'),
('STU045','CSE_SEM3_A','ADV002','Pankaj Gupta',5,'M','pankaj.gupta@college.edu','parent.pankaj@gmail.com'),
('STU046','CSE_SEM3_A','ADV002','Vandana Joshi',6,'F','vandana.joshi@college.edu','parent.vandana@gmail.com'),
('STU047','CSE_SEM3_A','ADV002','Mohan Verma',7,'M','mohan.verma@college.edu','parent.mohan@gmail.com'),
('STU048','CSE_SEM3_A','ADV002','Lata Mishra',8,'F','lata.mishra@college.edu','parent.lata@gmail.com'),
('STU049','CSE_SEM3_A','ADV002','Hemant Rao',9,'M','hemant.rao@college.edu','parent.hemant@gmail.com'),
('STU050','CSE_SEM3_A','ADV002','Shweta Reddy',10,'F','shweta.reddy@college.edu','parent.shweta@gmail.com'),
('STU051','CSE_SEM3_A','ADV002','Kunal Nair',11,'M','kunal.nair@college.edu','parent.kunal@gmail.com'),
('STU052','CSE_SEM3_A','ADV002','Pooja Pillai',12,'F','pooja.pillai@college.edu','parent.pooja@gmail.com'),
('STU053','CSE_SEM3_A','ADV002','Arjun Shah',13,'M','arjun.shah@college.edu','parent.arjun@gmail.com'),
('STU054','CSE_SEM3_A','ADV002','Riya Mehta',14,'F','riya.mehta@college.edu','parent.riya@gmail.com'),
('STU055','CSE_SEM3_A','ADV002','Sai Chopra',15,'M','sai.chopra@college.edu','parent.sai@gmail.com'),
('STU056','CSE_SEM3_A','ADV002','Reyansh Bose',16,'M','reyansh.bose@college.edu','parent.reyansh@gmail.com'),
('STU057','CSE_SEM3_A','ADV002','Ayaan Das',17,'M','ayaan.das@college.edu','parent.ayaan@gmail.com'),
('STU058','CSE_SEM3_A','ADV002','Nisha Iyer',18,'F','nisha.iyer@college.edu','parent.nisha@gmail.com'),
('STU059','CSE_SEM3_A','ADV002','Vihaan Menon',19,'M','vihaan.menon@college.edu','parent.vihaan@gmail.com'),
('STU060','CSE_SEM3_A','ADV002','Smita Chandra',20,'F','smita.chandra@college.edu','parent.smita@gmail.com'),
('STU061','CSE_SEM3_A','ADV002','Ritesh Kumar',21,'M','ritesh2.kumar@college.edu','parent.ritesh2@gmail.com'),
('STU062','CSE_SEM3_A','ADV002','Kavya Sharma',22,'F','kavya.sharma@college.edu','parent.kavya2@gmail.com'),
('STU063','CSE_SEM3_A','ADV002','Harsh Singh',23,'M','harsh.singh@college.edu','parent.harsh2@gmail.com'),
('STU064','CSE_SEM3_A','ADV002','Divya Patel',24,'F','divya.patel@college.edu','parent.divya2@gmail.com'),
('STU065','CSE_SEM3_A','ADV002','Nikhil Gupta',25,'M','nikhil.gupta@college.edu','parent.nikhil2@gmail.com'),
('STU066','CSE_SEM3_A','ADV002','Shreya Joshi',26,'F','shreya.joshi@college.edu','parent.shreya2@gmail.com'),
('STU067','CSE_SEM3_A','ADV002','Amit Verma',27,'M','amit.verma@college.edu','parent.amit2@gmail.com'),
('STU068','CSE_SEM3_A','ADV002','Kajal Mishra',28,'F','kajal.mishra@college.edu','parent.kajal2@gmail.com'),
('STU069','CSE_SEM3_A','ADV002','Ravi Rao',29,'M','ravi.rao@college.edu','parent.ravi2@gmail.com'),
('STU070','CSE_SEM3_A','ADV002','Sunita Reddy',30,'F','sunita.reddy@college.edu','parent.sunita2@gmail.com'),
('STU071','CSE_SEM3_A','ADV002','Manish Nair',31,'M','manish.nair@college.edu','parent.manish2@gmail.com'),
('STU072','CSE_SEM3_A','ADV002','Pallavi Pillai',32,'F','pallavi.pillai@college.edu','parent.pallavi2@gmail.com'),
('STU073','CSE_SEM3_A','ADV002','Gaurav Shah',33,'M','gaurav.shah@college.edu','parent.gaurav2@gmail.com'),
('STU074','CSE_SEM3_A','ADV002','Swati Mehta',34,'F','swati.mehta@college.edu','parent.swati2@gmail.com'),
('STU075','CSE_SEM3_A','ADV002','Deepak Chopra',35,'M','deepak.chopra@college.edu','parent.deepak2@gmail.com'),
('STU076','CSE_SEM3_A','ADV002','Rekha Bose',36,'F','rekha.bose@college.edu','parent.rekha2@gmail.com'),
('STU077','CSE_SEM3_A','ADV002','Sanjay Das',37,'M','sanjay.das@college.edu','parent.sanjay2@gmail.com'),
('STU078','CSE_SEM3_A','ADV002','Ankita Iyer',38,'F','ankita.iyer@college.edu','parent.ankita2@gmail.com'),
('STU079','CSE_SEM3_A','ADV002','Vikram Menon',39,'M','vikram.menon@college.edu','parent.vikram2@gmail.com'),
('STU080','CSE_SEM3_A','ADV002','Preeti Chandra',40,'F','preeti.chandra@college.edu','parent.preeti2@gmail.com');

-- Sem 5 students (STU081–STU120)
INSERT INTO students (student_id,class_id,advisor_id,name,roll_number,gender,email,parent_email) VALUES
('STU081','CSE_SEM5_A','ADV003','Aarav Sharma',1,'M','aarav.sharma@college.edu','parent.aarav2@gmail.com'),
('STU082','CSE_SEM5_A','ADV003','Vivaan Singh',2,'M','vivaan.singh@college.edu','parent.vivaan2@gmail.com'),
('STU083','CSE_SEM5_A','ADV003','Aditya Patel',3,'M','aditya.patel@college.edu','parent.aditya2@gmail.com'),
('STU084','CSE_SEM5_A','ADV003','Ananya Gupta',4,'F','ananya.gupta@college.edu','parent.ananya2@gmail.com'),
('STU085','CSE_SEM5_A','ADV003','Diya Joshi',5,'F','diya.joshi@college.edu','parent.diya2@gmail.com'),
('STU086','CSE_SEM5_A','ADV003','Priya Verma',6,'F','priya.verma@college.edu','parent.priya2@gmail.com'),
('STU087','CSE_SEM5_A','ADV003','Rahul Mishra',7,'M','rahul.mishra@college.edu','parent.rahul2@gmail.com'),
('STU088','CSE_SEM5_A','ADV003','Rohan Rao',8,'M','rohan.rao@college.edu','parent.rohan2@gmail.com'),
('STU089','CSE_SEM5_A','ADV003','Sneha Reddy',9,'F','sneha.reddy@college.edu','parent.sneha2@gmail.com'),
('STU090','CSE_SEM5_A','ADV003','Kiran Nair',10,'F','kiran.nair@college.edu','parent.kiran2@gmail.com'),
('STU091','CSE_SEM5_A','ADV003','Meera Pillai',11,'F','meera.pillai@college.edu','parent.meera2@gmail.com'),
('STU092','CSE_SEM5_A','ADV003','Ishaan Shah',12,'M','ishaan.shah@college.edu','parent.ishaan2@gmail.com'),
('STU093','CSE_SEM5_A','ADV003','Tanvi Mehta',13,'F','tanvi.mehta@college.edu','parent.tanvi2@gmail.com'),
('STU094','CSE_SEM5_A','ADV003','Yash Chopra',14,'M','yash.chopra@college.edu','parent.yash2@gmail.com'),
('STU095','CSE_SEM5_A','ADV003','Sakshi Bose',15,'F','sakshi.bose@college.edu','parent.sakshi2@gmail.com'),
('STU096','CSE_SEM5_A','ADV003','Dev Das',16,'M','dev.das@college.edu','parent.dev2@gmail.com'),
('STU097','CSE_SEM5_A','ADV003','Aryan Iyer',17,'M','aryan.iyer@college.edu','parent.aryan2@gmail.com'),
('STU098','CSE_SEM5_A','ADV003','Kavya Menon',18,'F','kavya.menon@college.edu','parent.kavya3@gmail.com'),
('STU099','CSE_SEM5_A','ADV003','Simran Chandra',19,'F','simran.chandra@college.edu','parent.simran2@gmail.com'),
('STU100','CSE_SEM5_A','ADV003','Harsh Kumar',20,'M','harsh.kumar@college.edu','parent.harsh3@gmail.com'),
('STU101','CSE_SEM5_A','ADV003','Neha Sharma',21,'F','neha.sharma@college.edu','parent.neha2@gmail.com'),
('STU102','CSE_SEM5_A','ADV003','Ritesh Singh',22,'M','ritesh.singh@college.edu','parent.ritesh3@gmail.com'),
('STU103','CSE_SEM5_A','ADV003','Divya Gupta',23,'F','divya.gupta@college.edu','parent.divya3@gmail.com'),
('STU104','CSE_SEM5_A','ADV003','Nikhil Joshi',24,'M','nikhil.joshi@college.edu','parent.nikhil3@gmail.com'),
('STU105','CSE_SEM5_A','ADV003','Shreya Verma',25,'F','shreya.verma@college.edu','parent.shreya3@gmail.com'),
('STU106','CSE_SEM5_A','ADV003','Amit Mishra',26,'M','amit.mishra@college.edu','parent.amit3@gmail.com'),
('STU107','CSE_SEM5_A','ADV003','Kajal Rao',27,'F','kajal.rao@college.edu','parent.kajal3@gmail.com'),
('STU108','CSE_SEM5_A','ADV003','Ravi Reddy',28,'M','ravi.reddy@college.edu','parent.ravi3@gmail.com'),
('STU109','CSE_SEM5_A','ADV003','Sunita Nair',29,'F','sunita.nair2@college.edu','parent.sunita3@gmail.com'),
('STU110','CSE_SEM5_A','ADV003','Manish Pillai',30,'M','manish.pillai@college.edu','parent.manish3@gmail.com'),
('STU111','CSE_SEM5_A','ADV003','Pallavi Shah',31,'F','pallavi.shah@college.edu','parent.pallavi3@gmail.com'),
('STU112','CSE_SEM5_A','ADV003','Gaurav Mehta',32,'M','gaurav.mehta@college.edu','parent.gaurav3@gmail.com'),
('STU113','CSE_SEM5_A','ADV003','Swati Chopra',33,'F','swati.chopra@college.edu','parent.swati3@gmail.com'),
('STU114','CSE_SEM5_A','ADV003','Deepak Bose',34,'M','deepak.bose@college.edu','parent.deepak3@gmail.com'),
('STU115','CSE_SEM5_A','ADV003','Rekha Das',35,'F','rekha.das@college.edu','parent.rekha3@gmail.com'),
('STU116','CSE_SEM5_A','ADV003','Sanjay Iyer',36,'M','sanjay.iyer@college.edu','parent.sanjay3@gmail.com'),
('STU117','CSE_SEM5_A','ADV003','Ankita Menon',37,'F','ankita.menon@college.edu','parent.ankita3@gmail.com'),
('STU118','CSE_SEM5_A','ADV003','Vikram Chandra',38,'M','vikram.chandra@college.edu','parent.vikram3@gmail.com'),
('STU119','CSE_SEM5_A','ADV003','Preeti Kumar',39,'F','preeti.kumar@college.edu','parent.preeti3@gmail.com'),
('STU120','CSE_SEM5_A','ADV003','Rajesh Sharma',40,'M','rajesh.sharma@college.edu','parent.rajesh2@gmail.com');

-- ── 4. SUBJECTS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subjects (
  subject_id      VARCHAR(15)  PRIMARY KEY,
  subject_name    VARCHAR(80)  NOT NULL,
  semester        INT          NOT NULL,
  credits         INT          DEFAULT 4,
  difficulty      VARCHAR(10)  DEFAULT 'Medium',
  subject_type    VARCHAR(20)  DEFAULT 'Core'
);

INSERT INTO subjects VALUES
-- Sem 1
('S1_MATH1',  'Mathematics I',            1, 4, 'Hard',   'Core'),
('S1_PHY',    'Physics',                  1, 4, 'Medium',  'Core'),
('S1_PROG',   'Programming Fundamentals', 1, 4, 'Medium',  'Core'),
('S1_ENG',    'English Communication',    1, 2, 'Easy',    'Foundation'),
('S1_DRAW',   'Engineering Drawing',      1, 2, 'Medium',  'Core'),
-- Sem 3
('S3_DISC',   'Discrete Mathematics',     3, 4, 'Hard',    'Core'),
('S3_CO',     'Computer Organisation',    3, 4, 'Hard',    'Core'),
('S3_DBMS',   'Database Management',      3, 4, 'Medium',  'Core'),
('S3_OS',     'Operating Systems',        3, 4, 'Hard',    'Core'),
('S3_SE',     'Software Engineering',     3, 3, 'Medium',  'Core'),
-- Sem 5
('S5_CD',     'Compiler Design',          5, 4, 'Hard',    'Core'),
('S5_AI',     'Artificial Intelligence',  5, 4, 'Hard',    'Core'),
('S5_CC',     'Cloud Computing',          5, 3, 'Medium',  'Core'),
('S5_MD',     'Mobile Development',       5, 3, 'Medium',  'Core'),
('S5_ELEC',   'Elective II',              5, 3, 'Medium',  'Elective');

-- ── 5. CLASS_SUBJECTS (which subjects a class studies) ─────────
CREATE TABLE IF NOT EXISTS class_subjects (
  class_id        VARCHAR(20),
  subject_id      VARCHAR(15),
  teacher_name    VARCHAR(80),
  PRIMARY KEY (class_id, subject_id),
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO class_subjects VALUES
('CSE_SEM1_A','S1_MATH1','Prof. Anil Kapoor'),
('CSE_SEM1_A','S1_PHY',  'Prof. Meena Desai'),
('CSE_SEM1_A','S1_PROG', 'Prof. Suresh Babu'),
('CSE_SEM1_A','S1_ENG',  'Prof. Rita Sharma'),
('CSE_SEM1_A','S1_DRAW', 'Prof. Kishore Rao'),
('CSE_SEM3_A','S3_DISC', 'Prof. Anil Kapoor'),
('CSE_SEM3_A','S3_CO',   'Prof. Venkat Rao'),
('CSE_SEM3_A','S3_DBMS', 'Prof. Suresh Babu'),
('CSE_SEM3_A','S3_OS',   'Prof. Pradeep Kumar'),
('CSE_SEM3_A','S3_SE',   'Prof. Latha Nair'),
('CSE_SEM5_A','S5_CD',   'Prof. Venkat Rao'),
('CSE_SEM5_A','S5_AI',   'Prof. Deepa Menon'),
('CSE_SEM5_A','S5_CC',   'Prof. Rajan Iyer'),
('CSE_SEM5_A','S5_MD',   'Prof. Pradeep Kumar'),
('CSE_SEM5_A','S5_ELEC', 'Prof. Latha Nair');

-- ── 6. EXAM SCHEDULE (known at week 0) ────────────────────────
-- The fact that midterm is in week 8 and endterm in week 16
-- is known before the semester starts. Individual results are
-- NOT here — they go into exam_results after the exam happens.

CREATE TABLE IF NOT EXISTS exam_schedule (
  schedule_id     VARCHAR(15)  PRIMARY KEY,
  class_id        VARCHAR(20)  NOT NULL,
  subject_id      VARCHAR(15)  NOT NULL,
  exam_type       VARCHAR(15)  NOT NULL,
  scheduled_week  INT          NOT NULL,
  exam_date       DATE,
  max_marks       INT          DEFAULT 50,
  duration_mins   INT          DEFAULT 120,
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Sem 1 exam schedule
INSERT INTO exam_schedule VALUES
('ES_S1M1_MID', 'CSE_SEM1_A','S1_MATH1','midterm', 8,'2024-09-15',50,120),
('ES_S1PH_MID', 'CSE_SEM1_A','S1_PHY',  'midterm', 8,'2024-09-16',50,120),
('ES_S1PR_MID', 'CSE_SEM1_A','S1_PROG', 'midterm', 8,'2024-09-17',50,120),
('ES_S1EN_MID', 'CSE_SEM1_A','S1_ENG',  'midterm', 8,'2024-09-18',50, 90),
('ES_S1DR_MID', 'CSE_SEM1_A','S1_DRAW', 'midterm', 8,'2024-09-19',50,120),
('ES_S1M1_END', 'CSE_SEM1_A','S1_MATH1','endterm',16,'2024-11-20',50,180),
('ES_S1PH_END', 'CSE_SEM1_A','S1_PHY',  'endterm',16,'2024-11-21',50,180),
('ES_S1PR_END', 'CSE_SEM1_A','S1_PROG', 'endterm',16,'2024-11-22',50,180),
('ES_S1EN_END', 'CSE_SEM1_A','S1_ENG',  'endterm',16,'2024-11-24',50,120),
('ES_S1DR_END', 'CSE_SEM1_A','S1_DRAW', 'endterm',16,'2024-11-25',50,120),
-- Sem 3 exam schedule
('ES_S3DC_MID', 'CSE_SEM3_A','S3_DISC', 'midterm', 8,'2024-09-15',50,120),
('ES_S3CO_MID', 'CSE_SEM3_A','S3_CO',   'midterm', 8,'2024-09-16',50,120),
('ES_S3DB_MID', 'CSE_SEM3_A','S3_DBMS', 'midterm', 8,'2024-09-17',50,120),
('ES_S3OS_MID', 'CSE_SEM3_A','S3_OS',   'midterm', 8,'2024-09-18',50,120),
('ES_S3SE_MID', 'CSE_SEM3_A','S3_SE',   'midterm', 8,'2024-09-19',50, 90),
('ES_S3DC_END', 'CSE_SEM3_A','S3_DISC', 'endterm',16,'2024-11-20',50,180),
('ES_S3CO_END', 'CSE_SEM3_A','S3_CO',   'endterm',16,'2024-11-21',50,180),
('ES_S3DB_END', 'CSE_SEM3_A','S3_DBMS', 'endterm',16,'2024-11-22',50,180),
('ES_S3OS_END', 'CSE_SEM3_A','S3_OS',   'endterm',16,'2024-11-24',50,180),
('ES_S3SE_END', 'CSE_SEM3_A','S3_SE',   'endterm',16,'2024-11-25',50,120),
-- Sem 5 exam schedule
('ES_S5CD_MID', 'CSE_SEM5_A','S5_CD',   'midterm', 8,'2024-09-15',50,120),
('ES_S5AI_MID', 'CSE_SEM5_A','S5_AI',   'midterm', 8,'2024-09-16',50,120),
('ES_S5CC_MID', 'CSE_SEM5_A','S5_CC',   'midterm', 8,'2024-09-17',50,120),
('ES_S5MD_MID', 'CSE_SEM5_A','S5_MD',   'midterm', 8,'2024-09-18',50,120),
('ES_S5EL_MID', 'CSE_SEM5_A','S5_ELEC', 'midterm', 8,'2024-09-19',50,120),
('ES_S5CD_END', 'CSE_SEM5_A','S5_CD',   'endterm',16,'2024-11-20',50,180),
('ES_S5AI_END', 'CSE_SEM5_A','S5_AI',   'endterm',16,'2024-11-21',50,180),
('ES_S5CC_END', 'CSE_SEM5_A','S5_CC',   'endterm',16,'2024-11-22',50,180),
('ES_S5MD_END', 'CSE_SEM5_A','S5_MD',   'endterm',16,'2024-11-24',50,180),
('ES_S5EL_END', 'CSE_SEM5_A','S5_ELEC', 'endterm',16,'2024-11-25',50,120);

-- ── 7. ASSIGNMENT DEFINITIONS (faculty schedule, known early) ──
-- What assignments exist and when they are due.
-- Follows two-peak distribution: heavy weeks 4-7, lighter 9-10,
-- heavy again 11-13, nothing in exam weeks 8 and 16.
-- assigned_week = when faculty gave it out (1-3 weeks before due)

CREATE TABLE IF NOT EXISTS assignment_definitions (
  assignment_id   VARCHAR(15)  PRIMARY KEY,
  class_id        VARCHAR(20)  NOT NULL,
  subject_id      VARCHAR(15)  NOT NULL,
  title           VARCHAR(120) NOT NULL,
  assigned_week   INT          NOT NULL,
  due_week        INT          NOT NULL,
  max_marks       INT          DEFAULT 10,
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO assignment_definitions VALUES
-- Sem 1 assignments (nothing in weeks 1-2, 8, 15-18)
('A_S1_001','CSE_SEM1_A','S1_MATH1','Algebra problem set',       3, 5, 10),
('A_S1_002','CSE_SEM1_A','S1_MATH1','Calculus assignment',       5, 7, 10),
('A_S1_003','CSE_SEM1_A','S1_MATH1','Statistics worksheet',      9,11, 10),
('A_S1_004','CSE_SEM1_A','S1_MATH1','Integration problems',     11,13, 10),
('A_S1_005','CSE_SEM1_A','S1_PHY',  'Lab report 1',             3, 5, 20),
('A_S1_006','CSE_SEM1_A','S1_PHY',  'Lab report 2',             9,11, 20),
('A_S1_007','CSE_SEM1_A','S1_PHY',  'Mechanics assignment',     12,14, 10),
('A_S1_008','CSE_SEM1_A','S1_PROG', 'Hello World to functions', 2, 4, 10),
('A_S1_009','CSE_SEM1_A','S1_PROG', 'Arrays and strings',       4, 6, 10),
('A_S1_010','CSE_SEM1_A','S1_PROG', 'Loops and conditionals',   5, 7, 10),
('A_S1_011','CSE_SEM1_A','S1_PROG', 'File handling program',    9,12, 10),
('A_S1_012','CSE_SEM1_A','S1_PROG', 'Mini project',            10,14, 25),
('A_S1_013','CSE_SEM1_A','S1_ENG',  'Technical writing essay',  3, 6,  10),
('A_S1_014','CSE_SEM1_A','S1_ENG',  'Presentation draft',       9,12, 10),
('A_S1_015','CSE_SEM1_A','S1_DRAW', 'Drawing set 1',            3, 6, 20),
('A_S1_016','CSE_SEM1_A','S1_DRAW', 'Drawing set 2',           11,13, 20),
-- Sem 3 assignments
('A_S3_001','CSE_SEM3_A','S3_DISC', 'Set theory problems',      3, 5, 10),
('A_S3_002','CSE_SEM3_A','S3_DISC', 'Graph theory assignment',  5, 7, 10),
('A_S3_003','CSE_SEM3_A','S3_DISC', 'Logic and proofs',         9,12, 10),
('A_S3_004','CSE_SEM3_A','S3_CO',   'Number systems worksheet', 3, 5, 10),
('A_S3_005','CSE_SEM3_A','S3_CO',   'Memory hierarchy report',  5, 7, 10),
('A_S3_006','CSE_SEM3_A','S3_CO',   'Instruction set analysis', 9,11, 10),
('A_S3_007','CSE_SEM3_A','S3_DBMS', 'ER diagram assignment',    2, 4, 10),
('A_S3_008','CSE_SEM3_A','S3_DBMS', 'SQL queries lab',          4, 6, 10),
('A_S3_009','CSE_SEM3_A','S3_DBMS', 'Normalisation problems',   6, 7, 10),
('A_S3_010','CSE_SEM3_A','S3_DBMS', 'Transaction management',   9,12, 10),
('A_S3_011','CSE_SEM3_A','S3_DBMS', 'Mini database project',   10,14, 25),
('A_S3_012','CSE_SEM3_A','S3_OS',   'Process scheduling lab',   4, 6, 10),
('A_S3_013','CSE_SEM3_A','S3_OS',   'Memory management report', 5, 7, 10),
('A_S3_014','CSE_SEM3_A','S3_OS',   'File system assignment',   9,12, 10),
('A_S3_015','CSE_SEM3_A','S3_SE',   'Requirements document',    4, 6, 20),
('A_S3_016','CSE_SEM3_A','S3_SE',   'Design document',          11,13, 20),
-- Sem 5 assignments
('A_S5_001','CSE_SEM5_A','S5_CD',   'Lexer implementation',     3, 5, 10),
('A_S5_002','CSE_SEM5_A','S5_CD',   'Parser assignment',        5, 7, 10),
('A_S5_003','CSE_SEM5_A','S5_CD',   'Code generation lab',      9,12, 10),
('A_S5_004','CSE_SEM5_A','S5_AI',   'Search algorithms lab',    3, 5, 10),
('A_S5_005','CSE_SEM5_A','S5_AI',   'Knowledge representation', 5, 7, 10),
('A_S5_006','CSE_SEM5_A','S5_AI',   'ML basics assignment',     9,11, 10),
('A_S5_007','CSE_SEM5_A','S5_AI',   'AI mini project',         10,14, 25),
('A_S5_008','CSE_SEM5_A','S5_CC',   'Cloud deployment lab',     4, 6, 10),
('A_S5_009','CSE_SEM5_A','S5_CC',   'Serverless functions',     9,12, 10),
('A_S5_010','CSE_SEM5_A','S5_MD',   'Android app prototype',    4, 7, 20),
('A_S5_011','CSE_SEM5_A','S5_MD',   'App with API integration',11,14, 20),
('A_S5_012','CSE_SEM5_A','S5_ELEC', 'Elective report 1',        5, 7, 10),
('A_S5_013','CSE_SEM5_A','S5_ELEC', 'Elective report 2',       11,13, 10);

-- ── 8. QUIZ DEFINITIONS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_definitions (
  quiz_id         VARCHAR(15)  PRIMARY KEY,
  class_id        VARCHAR(20)  NOT NULL,
  subject_id      VARCHAR(15)  NOT NULL,
  title           VARCHAR(100) NOT NULL,
  scheduled_week  INT          NOT NULL,
  quiz_date       DATE,
  max_marks       INT          DEFAULT 10,
  duration_mins   INT          DEFAULT 20,
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO quiz_definitions VALUES
-- Sem 1 quizzes (not in weeks 1, 8, 16)
('Q_S1_001','CSE_SEM1_A','S1_MATH1','Maths Quiz 1',        4,'2024-08-13',10,20),
('Q_S1_002','CSE_SEM1_A','S1_MATH1','Maths Quiz 2',       12,'2024-10-15',10,20),
('Q_S1_003','CSE_SEM1_A','S1_PHY',  'Physics Quiz 1',      5,'2024-08-20',10,20),
('Q_S1_004','CSE_SEM1_A','S1_PHY',  'Physics Quiz 2',     13,'2024-10-22',10,20),
('Q_S1_005','CSE_SEM1_A','S1_PROG', 'Programming Quiz 1',  4,'2024-08-13',10,20),
('Q_S1_006','CSE_SEM1_A','S1_PROG', 'Programming Quiz 2',  6,'2024-08-27',10,20),
('Q_S1_007','CSE_SEM1_A','S1_PROG', 'Programming Quiz 3', 11,'2024-10-08',10,20),
-- Sem 3 quizzes
('Q_S3_001','CSE_SEM3_A','S3_DISC', 'Discrete Maths Q1',   4,'2024-08-13',10,20),
('Q_S3_002','CSE_SEM3_A','S3_DISC', 'Discrete Maths Q2',  12,'2024-10-15',10,20),
('Q_S3_003','CSE_SEM3_A','S3_CO',   'CO Quiz 1',           5,'2024-08-20',10,20),
('Q_S3_004','CSE_SEM3_A','S3_CO',   'CO Quiz 2',          13,'2024-10-22',10,20),
('Q_S3_005','CSE_SEM3_A','S3_DBMS', 'DBMS Quiz 1',         3,'2024-08-06',10,20),
('Q_S3_006','CSE_SEM3_A','S3_DBMS', 'DBMS Quiz 2',         6,'2024-08-27',10,20),
('Q_S3_007','CSE_SEM3_A','S3_DBMS', 'DBMS Quiz 3',        11,'2024-10-08',10,20),
('Q_S3_008','CSE_SEM3_A','S3_OS',   'OS Quiz 1',           5,'2024-08-20',10,20),
('Q_S3_009','CSE_SEM3_A','S3_OS',   'OS Quiz 2',          12,'2024-10-15',10,20),
-- Sem 5 quizzes
('Q_S5_001','CSE_SEM5_A','S5_CD',   'Compiler Design Q1',  4,'2024-08-13',10,20),
('Q_S5_002','CSE_SEM5_A','S5_CD',   'Compiler Design Q2', 12,'2024-10-15',10,20),
('Q_S5_003','CSE_SEM5_A','S5_AI',   'AI Quiz 1',           5,'2024-08-20',10,20),
('Q_S5_004','CSE_SEM5_A','S5_AI',   'AI Quiz 2',           6,'2024-08-27',10,20),
('Q_S5_005','CSE_SEM5_A','S5_AI',   'AI Quiz 3',          13,'2024-10-22',10,20),
('Q_S5_006','CSE_SEM5_A','S5_CC',   'Cloud Quiz 1',        5,'2024-08-20',10,20),
('Q_S5_007','CSE_SEM5_A','S5_MD',   'Mobile Dev Quiz 1',   6,'2024-08-27',10,20),
('Q_S5_008','CSE_SEM5_A','S5_MD',   'Mobile Dev Quiz 2',  11,'2024-10-08',10,20);

-- One row. One global week. All classes move together.
CREATE TABLE IF NOT EXISTS sim_state (
  id              INT PRIMARY KEY DEFAULT 1,
  current_week    INT NOT NULL DEFAULT 0,
  semester_start  DATE NOT NULL DEFAULT '2024-07-15',
  last_updated    DATETIME DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT single_row CHECK (id = 1)
);

INSERT INTO sim_state (id, current_week, semester_start)
VALUES (1, 0, '2024-07-15')
ON DUPLICATE KEY UPDATE id = 1;

-- ── 10. TRANSACTIONAL TABLES (schema only, zero rows at week 0) 
-- These fill up as the simulator advances weeks.

CREATE TABLE IF NOT EXISTS attendance (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  subject_id      VARCHAR(15)  NOT NULL,
  week            INT          NOT NULL,
  week_date       DATE         NOT NULL,
  lectures_held   INT          DEFAULT 3,
  present         INT,
  absent          INT,
  late            INT,
  attendance_pct  DECIMAL(5,2),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (class_id)   REFERENCES classes(class_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
  UNIQUE KEY uq_att (student_id, subject_id, week)
);

CREATE TABLE IF NOT EXISTS assignment_submissions (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  assignment_id   VARCHAR(15)  NOT NULL,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  status          VARCHAR(15)  NOT NULL DEFAULT 'pending',
  submission_date DATETIME,
  latency_hours   DECIMAL(6,1),
  marks_obtained  DECIMAL(5,2),
  quality_pct     DECIMAL(5,2),
  plagiarism_pct  DECIMAL(5,2) DEFAULT 0,
  FOREIGN KEY (assignment_id) REFERENCES assignment_definitions(assignment_id),
  FOREIGN KEY (student_id)    REFERENCES students(student_id),
  UNIQUE KEY uq_sub (assignment_id, student_id)
);

CREATE TABLE IF NOT EXISTS quiz_submissions (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  quiz_id         VARCHAR(15)  NOT NULL,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  attempted       TINYINT(1)   DEFAULT 0,
  attempt_date    DATETIME,
  marks_obtained  DECIMAL(5,2),
  score_pct       DECIMAL(5,2),
  FOREIGN KEY (quiz_id)    REFERENCES quiz_definitions(quiz_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  UNIQUE KEY uq_qsub (quiz_id, student_id)
);

CREATE TABLE IF NOT EXISTS library_visits (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  week            INT          NOT NULL,
  week_date       DATE,
  physical_visits INT          DEFAULT 0,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  UNIQUE KEY uq_lib (student_id, week)
);

CREATE TABLE IF NOT EXISTS book_borrows (
  borrow_id       VARCHAR(15)  PRIMARY KEY,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  book_title      VARCHAR(120),
  borrow_date     DATE,
  return_date     DATE,
  borrow_week     INT,
  return_week     INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);

CREATE TABLE IF NOT EXISTS exam_results (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  schedule_id     VARCHAR(15)  NOT NULL,
  student_id      VARCHAR(10)  NOT NULL,
  class_id        VARCHAR(20)  NOT NULL,
  marks_obtained  DECIMAL(5,2),
  max_marks       INT,
  score_pct       DECIMAL(5,2),
  pass_fail       CHAR(1),
  grade           VARCHAR(5),
  result_date     DATE,
  FOREIGN KEY (schedule_id) REFERENCES exam_schedule(schedule_id),
  FOREIGN KEY (student_id)  REFERENCES students(student_id),
  UNIQUE KEY uq_result (schedule_id, student_id)
);

-- ── 11. INDEXES ────────────────────────────────────────────────
CREATE INDEX idx_att_student_week  ON attendance(student_id, week);
CREATE INDEX idx_att_class_week    ON attendance(class_id, week);
CREATE INDEX idx_sub_student       ON assignment_submissions(student_id);
CREATE INDEX idx_sub_assignment    ON assignment_submissions(assignment_id);
CREATE INDEX idx_qsub_student      ON quiz_submissions(student_id);
CREATE INDEX idx_lib_student_week  ON library_visits(student_id, week);
CREATE INDEX idx_result_student    ON exam_results(student_id);
CREATE INDEX idx_result_schedule   ON exam_results(schedule_id);


USE edumetrics_client;

-- Step 1: Add the column
ALTER TABLE students
ADD COLUMN archetype VARCHAR(30) DEFAULT 'consistent_avg';

-- ── SEM 1 (STU001–STU040) ──────────────────────────────────────

UPDATE students SET archetype = 'high_performer' WHERE student_id IN
('STU002','STU005','STU011','STU018','STU025','STU033');

UPDATE students SET archetype = 'consistent_avg' WHERE student_id IN
('STU001','STU004','STU007','STU010','STU013','STU016',
 'STU019','STU022','STU028','STU034','STU039');

UPDATE students SET archetype = 'late_bloomer' WHERE student_id IN
('STU008','STU020','STU030','STU037');

UPDATE students SET archetype = 'slow_fader' WHERE student_id IN
('STU003','STU009','STU015','STU024','STU031','STU038');

UPDATE students SET archetype = 'crammer' WHERE student_id IN
('STU006','STU017','STU027','STU036');

UPDATE students SET archetype = 'crisis_student' WHERE student_id IN
('STU012','STU021','STU032','STU040');

UPDATE students SET archetype = 'silent_disengager' WHERE student_id IN
('STU014','STU023','STU026','STU029','STU035');

-- ── SEM 3 (STU041–STU080) ──────────────────────────────────────

UPDATE students SET archetype = 'high_performer' WHERE student_id IN
('STU042','STU049','STU055','STU062','STU070','STU078');

UPDATE students SET archetype = 'consistent_avg' WHERE student_id IN
('STU041','STU044','STU047','STU051','STU056','STU060',
 'STU063','STU067','STU072','STU075','STU079');

UPDATE students SET archetype = 'late_bloomer' WHERE student_id IN
('STU048','STU058','STU068','STU076');

UPDATE students SET archetype = 'slow_fader' WHERE student_id IN
('STU043','STU052','STU059','STU065','STU073','STU080');

UPDATE students SET archetype = 'crammer' WHERE student_id IN
('STU046','STU054','STU064','STU074');

UPDATE students SET archetype = 'crisis_student' WHERE student_id IN
('STU050','STU061','STU069','STU077');

UPDATE students SET archetype = 'silent_disengager' WHERE student_id IN
('STU045','STU053','STU057','STU066','STU071');

-- ── SEM 5 (STU081–STU120) ──────────────────────────────────────

UPDATE students SET archetype = 'high_performer' WHERE student_id IN
('STU082','STU089','STU095','STU102','STU110','STU118');

UPDATE students SET archetype = 'consistent_avg' WHERE student_id IN
('STU081','STU084','STU087','STU091','STU096','STU100',
 'STU103','STU107','STU112','STU115','STU119');

UPDATE students SET archetype = 'late_bloomer' WHERE student_id IN
('STU088','STU098','STU108','STU116');

UPDATE students SET archetype = 'slow_fader' WHERE student_id IN
('STU083','STU092','STU099','STU105','STU113','STU120');

UPDATE students SET archetype = 'crammer' WHERE student_id IN
('STU086','STU094','STU104','STU114');

UPDATE students SET archetype = 'crisis_student' WHERE student_id IN
('STU090','STU101','STU109','STU117');

UPDATE students SET archetype = 'silent_disengager' WHERE student_id IN
('STU085','STU093','STU097','STU106','STU111');

-- ── Verify ────────────────────────────────────────────────────
SELECT
    archetype,
    COUNT(*) AS total,
    SUM(CASE WHEN class_id = 'CSE_SEM1_A' THEN 1 ELSE 0 END) AS sem1,
    SUM(CASE WHEN class_id = 'CSE_SEM3_A' THEN 1 ELSE 0 END) AS sem3,
    SUM(CASE WHEN class_id = 'CSE_SEM5_A' THEN 1 ELSE 0 END) AS sem5
FROM students
GROUP BY archetype
ORDER BY total DESC;
