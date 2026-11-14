// Safe on an existing database; never drops collections or documents.
const met = db.getSiblingDB('metricare_nosql');
for (const name of ['patients','consultations']) {
  if (!met.getCollectionNames().includes(name)) met.createCollection(name);
}
// Logical identifiers, distinct from MongoDB's generated _id values.
met.patients.createIndex({patientId:1},{unique:true,name:'uq_patientId'});
met.consultations.createIndex({consultationId:1},{unique:true,name:'uq_consultationId'});
print('Database: ' + met.getName());
print('Collections: ' + met.getCollectionNames().join(', '));
print('Patients: ' + met.patients.countDocuments({}));
print('Consultations: ' + met.consultations.countDocuments({}));
