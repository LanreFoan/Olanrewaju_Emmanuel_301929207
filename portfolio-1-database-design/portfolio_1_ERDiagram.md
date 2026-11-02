# MeriCare specialist hospital management system (simulated) ER Diagram


```mermaid
erDiagram
	direction LR
	PATIENT {
		INTEGER PatientID PK ""  
		VARCHAR FullName  ""  
		DATE DateOfBirth  ""  
		VARCHAR Phone  "Optional"  
	}

	DEPARTMENT {
		INTEGER DepartmentID PK ""  
		VARCHAR DepartmentName UK ""  
	}

	STAFF {
		INTEGER StaffID PK ""  
		VARCHAR FullName  ""  
		VARCHAR Role  ""  
		INTEGER DepartmentID FK "Optional for non-doctors"  
	}

	APPOINTMENT {
		INTEGER AppointmentID PK ""  
		INTEGER PatientID FK ""  
		INTEGER DoctorID FK ""  
		TIMESTAMP AppointmentDateTime  ""  
		VARCHAR Status  ""  
	}

	CONSULTATION {
		INTEGER ConsultationID PK ""  
		INTEGER AppointmentID FK,UK ""  
		TEXT Notes  "Optional"  
	}

	DIAGNOSIS {
		INTEGER DiagnosisID PK ""  
		INTEGER ConsultationID FK ""  
		VARCHAR DiagnosisName  ""  
	}

	LAB_REQUEST {
		INTEGER LabRequestID PK ""  
		INTEGER PatientID FK ""  
		INTEGER DoctorID FK ""  
		INTEGER ConsultationID FK "Optional"  
		VARCHAR TestType  ""  
		VARCHAR Status  ""  
		TEXT Result  "Optional"  
	}

	PRESCRIPTION {
		INTEGER PrescriptionID PK ""  
		INTEGER PatientID FK ""  
		INTEGER DoctorID FK ""  
		INTEGER ConsultationID FK "Optional"  
		DATE PrescriptionDate  ""  
	}

	PRESCRIPTION_MEDICATION {
		INTEGER PrescriptionMedicationID PK ""  
		INTEGER PrescriptionID FK ""  
		VARCHAR MedicationName  ""  
		VARCHAR Dosage  ""  
		VARCHAR Frequency  ""  
	}

	INVOICE {
		INTEGER InvoiceID PK ""  
		INTEGER PatientID FK ""  
		NUMERIC InvoiceAmount  ""  
	}

	PAYMENT {
		INTEGER PaymentID PK ""  
		INTEGER InvoiceID FK ""  
		NUMERIC Amount  ""  
		DATE PaymentDate  ""  
	}

	PATIENT||--o{APPOINTMENT:"books"
	STAFF||--o{APPOINTMENT:"attends"
	DEPARTMENT|o--o{STAFF:"employs"
	APPOINTMENT||--o|CONSULTATION:"produces"
	CONSULTATION||--o{DIAGNOSIS:"records"
	STAFF||--o{LAB_REQUEST:"requests"
	CONSULTATION|o--o{LAB_REQUEST:"relates_to"
	PATIENT||--o{PRESCRIPTION:"receives"
	STAFF||--o{PRESCRIPTION:"issues"
	CONSULTATION|o--o{PRESCRIPTION:"relates_to"
	PRESCRIPTION ||--|{ PRESCRIPTION_MEDICATION : contains
	PATIENT||--o{INVOICE:"receives"
	INVOICE||--o{PAYMENT:"has"
```

## Explanation of Keys and Relationships

### Primary Key (PK)
A primary key uniquely identifies each record in a table. For example, `PatientID` identifies each patient and cannot be duplicated.

### Foreign Key (FK)
A foreign key connects a record to another table. For example, `PatientID` in the `APPOINTMENT` table identifies the patient associated with an appointment.

### Unique Key (UK)
A unique key prevents duplicate values in a field or combination of fields. For example, `DepartmentName` must be unique. The unique `AppointmentID` reference in `CONSULTATION` ensures that an appointment has at most one consultation.

### Relationship Symbols
`||` means exactly one,
`o{` means zero or many,
`o|` means zero or one,
`|{` means One or many

**For example, `PATIENT ||--o{ APPOINTMENT` means that each appointment belongs to exactly one patient, while a patient can have zero or many appointments.
