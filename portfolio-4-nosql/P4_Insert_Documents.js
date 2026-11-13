// MetriCare Portfolio 4: fictional demonstration documents.
// Run after P4_Create_Database.js.
// $setOnInsert avoids duplicates and preserves changes made to existing records.

const met = db.getSiblingDB('metricare_nosql');
const patients = [
 {patientId:1,fullName:'Adaeze Okafor',dateOfBirth:ISODate('1990-05-14'),phone:'08000000001',gender:'Female'},
 {patientId:2,fullName:'Tunde Bello',dateOfBirth:ISODate('1985-09-22'),phone:'08000000002',gender:'Male'},
 {patientId:3,fullName:'Mariam Yusuf',dateOfBirth:ISODate('1995-02-10'),phone:'08000000003',gender:'Female'}
];
const consultations = [
 {consultationId:1001,patientId:1,doctor:{staffId:1,fullName:'Dr Chika Nwosu',department:'Internal Medicine'},consultationDate:ISODate('2026-11-10'),notes:'Patient presented for blood pressure review.',diagnoses:[{diagnosisName:'Hypertension',status:'Confirmed'}],laboratoryRequests:[{labRequestId:501,testType:'Lipid Profile',status:'Pending',result:null}],prescriptions:[{medicationName:'Amlodipine',dosage:'5 mg',frequency:'Once daily'}]},
 {consultationId:1002,patientId:2,doctor:{staffId:2,fullName:'Dr Femi Adeyemi',department:'Orthopaedics'},consultationDate:ISODate('2026-11-11'),notes:'Patient reported persistent knee discomfort.',diagnoses:[{diagnosisName:'Knee Osteoarthritis',status:'Confirmed'}],laboratoryRequests:[{labRequestId:502,testType:'ESR',status:'Completed',result:'18 mm/hr'}],prescriptions:[{medicationName:'Paracetamol',dosage:'500 mg',frequency:'Three times daily'}]},
 {consultationId:1003,patientId:3,doctor:{staffId:1,fullName:'Dr Chika Nwosu',department:'Internal Medicine'},consultationDate:ISODate('2026-11-12'),notes:'Patient presented with fatigue.',diagnoses:[{diagnosisName:'Anaemia',status:'Provisional'}],laboratoryRequests:[{labRequestId:503,testType:'Full Blood Count',status:'Pending',result:null}],prescriptions:[]}
];
for (const p of patients) printjson(met.patients.updateOne({patientId:p.patientId},{$setOnInsert:p},{upsert:true}));
for (const c of consultations) printjson(met.consultations.updateOne({consultationId:c.consultationId},{$setOnInsert:c},{upsert:true}));
print('Patient count: '+met.patients.countDocuments({patientId:{$in:[1,2,3]}}));
print('Consultation count: '+met.consultations.countDocuments({consultationId:{$in:[1001,1002,1003]}}));
printjson(met.consultations.find({},{_id:0,consultationId:1,patientId:1,diagnoses:1}).sort({consultationId:1}).toArray());
