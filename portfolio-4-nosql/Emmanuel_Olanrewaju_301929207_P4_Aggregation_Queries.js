// Portfolio 4 — diagnosis reporting via MongoDB aggregation.
const met = db.getSiblingDB('metricare_nosql');
print('Diagnosis counts (one diagnosis-array element per count):');
printjson(met.consultations.aggregate([
 {$unwind:'$diagnoses'},
 {$group:{_id:'$diagnoses.diagnosisName',totalConsultations:{$sum:1}}},
 {$sort:{totalConsultations:-1,_id:1}}
]).toArray());
print('Final sample document counts:');
print('patients='+met.patients.countDocuments({patientId:{$in:[1,2,3]}}));
print('consultations='+met.consultations.countDocuments({consultationId:{$in:[1001,1002,1003]}}));
