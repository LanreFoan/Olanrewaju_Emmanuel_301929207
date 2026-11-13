// Run after P4_Insert_Documents.js; on a previously completed database the
// update may report modifiedCount:0 because the lab result already matches.
const met = db.getSiblingDB('metricare_nosql');
print('READ: Patient 1 consultation');
printjson(met.consultations.find({patientId:1},{_id:0,consultationId:1,consultationDate:1,diagnoses:1,prescriptions:1}).toArray());
print('READ: Embedded hypertension diagnosis');
printjson(met.consultations.find({'diagnoses.diagnosisName':'Hypertension'},{_id:0,consultationId:1,patientId:1,diagnoses:1}).toArray());
print('UPDATE: Complete laboratory request 501');
const update=met.consultations.updateOne(
 {consultationId:1001,laboratoryRequests:{$elemMatch:{labRequestId:501,status:'Pending'}}},
 {$set:{'laboratoryRequests.$.status':'Completed','laboratoryRequests.$.result':'Within reference limits'}}
);
printjson(update);
print('VERIFY: Lab request after update');
printjson(met.consultations.find({consultationId:1001},{_id:0,consultationId:1,laboratoryRequests:1}).toArray());
print('READ: Consultations containing a pending lab request');
printjson(met.consultations.find({'laboratoryRequests.status':'Pending'},{_id:0,consultationId:1,patientId:1,laboratoryRequests:1}).toArray());
print('CREATE: Temporary test patient (only if not already present)');
printjson(met.patients.updateOne({patientId:999},{$setOnInsert:{patientId:999,fullName:'Temporary Test Patient',dateOfBirth:ISODate('2000-01-01'),phone:'08000000999',gender:'Other',testRecord:true}},{upsert:true}));
print('VERIFY: Temporary patient before deletion');
printjson(met.patients.find({patientId:999,testRecord:true},{_id:0}).toArray());
print('DELETE: Only the explicitly tagged temporary patient');
printjson(met.patients.deleteOne({patientId:999,testRecord:true}));
print('VERIFY: Temporary patient count: '+met.patients.countDocuments({patientId:999,testRecord:true}));
