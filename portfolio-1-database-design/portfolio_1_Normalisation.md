# Hospital Management System Normalisation

Normalisation separates information into related tables to reduce repeated details and prevent inconsistent updates. This example uses simulated hospital records to demonstrate First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF).

The same three simulated appointments are used throughout the example. Only the fields needed to explain normalisation are shown; the complete database design retains the other fields already defined.

## Starting Record: Repeated List

Suppose a hospital records patient details, doctor details, and appointment information in one table.

 | PatientID | PatientName | DoctorID | DoctorName | Appointments |
 | --- | ---| --- | --- | --- |
 | 1 | Adaeze Okafor | 1 | Dr. Chika Nwosu |  Appointment 101: 10 Nov 2026, 09:00; Appointment 102: 10 Nov 2026, 10:00 |
 | 2 | Tunde Bello |   1 | Dr. Chika Nwosu |    Appointment 103: 10 Nov 2026, 11:00 |

The first row contains two appointments in one cell. Finding, updating, or cancelling one appointment becomes difficult because multiple records are stored together.

**Problem:** Appointment information is not stored as one separate record per appointment, and patient and doctor details are repeated.

## 1NF: One Value Per Cell

**First Normal Form (1NF)** means each cell contains one value, and each record represents one occurrence.

Each appointment now has its own row.

  |AppointmentID (PK) | PatientID  | PatientName |  DoctorID |  DoctorName |  AppointmentDateTime  | DepartmentName|
  | --- | ---| --- | --- | --- | --- | --- |
  | 101  | 1 | Adaeze Okafor | 1 | Dr. Chika Nwosu | 2026-11-10 09:00  | General Medicine |                                                                             
  |102 | 1 |Adaeze Okafor | 1    | Dr. Chika Nwosu | 2026-11-10 10:00    |  General Medicine |                      
  |103  |   2    | Tunde Bello |  1 | Dr. Chika Nwosu | 2026-11-10 11:00    |  General Medicine  |
                                                                                     

**Primary key:** `AppointmentID` uniquely identifies each appointment.

**What changes:** The repeated appointment list is separated into individual records. Each row represents one appointment, making it easier to locate or update a specific appointment.

**What remains:** Patient names, doctor names, and department names repeat across rows. Changing Dr. Cole's name or the department name may require updates in several records.

## 2NF: Remove Partial Dependencies

**Second Normal Form (2NF)** means the table is in 1NF, and every non-key field depends on the whole primary key, not just part of a combined key.

In this example, `AppointmentID` is a single-column primary key, not a combined key. Therefore, there are no partial dependencies, and the 1NF table is already in 2NF.

However, patient and doctor details still repeat. These details describe patients and staff members rather than the appointments themselves. Separating them prepares the design for 3NF.

**Assumptions:**
- Each `PatientID` identifies one patient.
- Each `DoctorID` identifies one doctor.
- Each `AppointmentID` identifies one appointment.

## 3NF: Keep Details With the Entity They Describe

**Third Normal Form (3NF)** means the table is in 2NF, and non-key fields depend on the key, the whole key, and nothing but the key. In simple terms, information about a patient belongs in the patient table, while information about a doctor belongs in the staff table.

The following dependencies explain the separation:

- `PatientID` determines `PatientName`. The patient's name describes the patient, not the appointment.
- `DoctorID` determines the doctor's name and department assignment. These details describe the staff member, not the appointment.
- `DepartmentID` determines `DepartmentName`. The department name describes the department, not the doctor or appointment.

### Patient

**Primary key:** `PatientID`

  |PatientID (PK)  | FullName
 | --- | ---|
  |1       |         Adaeze Okafor |
 | 2          |      Tunde Bello |

Each patient's name is stored once, avoiding repeated patient details across appointments.

### Department

**Primary key:** `DepartmentID`

  | DepartmentID (PK) |  DepartmentName |
 | --- | ---|
 |1     |   General Medicine |

The department name is stored separately rather than repeated for every doctor or appointment.

### Staff

**Primary key:** `StaffID`  
**Foreign key:** `DepartmentID` references `Department`.

  |StaffID (PK) |   FullName    |      Role  |   DepartmentID (FK) |
 | --- | ---| --- | --- |
 | 1  |   Dr. Chika Nwosu |  Doctor  | 1|

The staff table stores the doctor's details once. The department ID connects the doctor to Cardiology.

### Appointment

**Primary key:** `AppointmentID`  
**Foreign keys:** `PatientID` references `Patient`; `DoctorID` references `Staff`.

  AppointmentID (PK) | PatientID (FK) | DoctorID (FK) |  AppointmentDateTime |
 | --- | ---| --- | --- |
 | 101  |  1  |   1   |  2026-11-10 09:00 |
 | 102  | 1  |  1  |  2026-11-10 10:00 |
 | 103 |  2  |  1  | 2026-11-10 11:00 |

The appointment table stores appointment-specific information and uses foreign keys to connect each appointment to its patient and doctor.

### How the IDs Keep the Tables Connected

For example, Appointment 101 has `PatientID = 1` and `DoctorID = 10`. These IDs connect the appointment to Ada James in the Patient table and Dr. Cole in the Staff table. The doctor's `DepartmentID = 1` connects the staff record to Cardiology in the Department table.

The final design uses `AppointmentID` as the primary key rather than a combined key such as `(PatientID, AppointmentDateTime)`. This allows a patient to have multiple appointments without relying on appointment dates to identify records.

**Important:** Adding an ID alone does not establish 3NF. The separation of patient, staff, and department details removes the unwanted dependencies.


The four tables above demonstrate normalisation using appointment records. The complete hospital database retains all agreed entities
The examples omit other fields for readability, including patient date of birth and phone number; appointment status; consultation notes; diagnosis names; laboratory test types, statuses, and results; prescription dates; medication names, dosages, and frequencies; invoice amounts; and payment amounts and dates.

