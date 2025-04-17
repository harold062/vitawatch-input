import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_database/firebase_database.dart'; // Add this import

class EntityForm extends StatefulWidget {
  const EntityForm({super.key});

  @override
  _EntityFormState createState() => _EntityFormState();
}

class _EntityFormState extends State<EntityForm> {
  final _formKey = GlobalKey<FormState>();

  // Create database reference
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Patient fields
  String? patientID,
      patientName,
      age,
      contactInfo,
      assignedDeviceID,
      caregiverID;

  // Caregiver fields
  String? caregiverIDField, caregiverName, caregiverRole, caregiverContact;

  // Device fields
  String? deviceID, model, deviceStatus, patientIDForDevice;

  // Function to save patient data
  Future<void> _savePatientData() async {
    if (patientID != null && patientID!.isNotEmpty) {
      await _database.child('patients').child(patientID!).set({
        'name': patientName,
        'age': age,
        'contactInfo': contactInfo,
        'assignedDeviceID': assignedDeviceID,
        'caregiverID': caregiverID,
      });
    }
  }

  // Function to save caregiver data
  Future<void> _saveCaregiverData() async {
    if (caregiverIDField != null && caregiverIDField!.isNotEmpty) {
      await _database.child('caregivers').child(caregiverIDField!).set({
        'name': caregiverName,
        'role': caregiverRole,
        'contactInfo': caregiverContact,
      });
    }
  }

  // Function to save device data
  Future<void> _saveDeviceData() async {
    if (deviceID != null && deviceID!.isNotEmpty) {
      await _database.child('devices').child(deviceID!).set({
        'model': model,
        'status': deviceStatus,
        'patientID': patientIDForDevice,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entity Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PATIENT SECTION
              sectionTitle("Patient"),
              buildTextField('Patient ID', (val) => patientID = val),
              buildTextField('Name', (val) => patientName = val),
              buildTextField(
                'Age',
                (val) => age = val,
                inputType: TextInputType.number,
              ),
              buildTextField('Contact Info', (val) => contactInfo = val),
              buildTextField(
                'Assigned Device ID',
                (val) => assignedDeviceID = val,
              ),
              buildTextField('Caregiver ID', (val) => caregiverID = val),

              const SizedBox(height: 20),

              /// CAREGIVER SECTION
              sectionTitle("Caregiver"),
              buildTextField('Caregiver ID', (val) => caregiverIDField = val),
              buildTextField('Name', (val) => caregiverName = val),
              buildTextField('Role', (val) => caregiverRole = val),
              buildTextField('Contact Info', (val) => caregiverContact = val),

              const SizedBox(height: 20),

              /// DEVICE SECTION
              sectionTitle("Device"),
              buildTextField('Device ID', (val) => deviceID = val),
              buildTextField('Model', (val) => model = val),
              buildTextField('Status', (val) => deviceStatus = val),
              buildTextField(
                'Patient ID (linked)',
                (val) => patientIDForDevice = val,
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState != null) {
                      _formKey.currentState!.save();

                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saving data...')),
                      );

                      try {
                        // Save all data to Firebase
                        await _savePatientData();
                        await _saveCaregiverData();
                        await _saveDeviceData();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data saved successfully!'),
                          ),
                        );
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving data: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    Function(String?) onSaved, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: inputType,
      onSaved: onSaved,
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
