import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentTabIndex = 0;

  // Liste des onglets
  final List<String> _tabs = [
    'Profil',
    'Médical',
    'Documents',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D8B8B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0D8B8B)),
            onPressed: () {
              _showEditProfileOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF0D8B8B)),
            onPressed: () {
              _showSettingsOptions();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D8B8B),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          
          return Column(
            children: [
              // En-tête avec photo et informations de base
              _buildProfileHeader(userData),

              // Onglets
              Container(
                color: Colors.white,
                child: Row(
                  children: List.generate(
                    _tabs.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentTabIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _currentTabIndex == index
                                    ? const Color(0xFF0D8B8B)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _currentTabIndex == index
                                  ? const Color(0xFF0D8B8B)
                                  : Colors.grey,
                              fontWeight: _currentTabIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Contenu de l'onglet sélectionné
              Expanded(
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    _buildProfileTab(userData),
                    _buildMedicalTab(),
                    _buildDocumentsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Age: ${userData['age']?.toString() ?? '0'} ans',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D8B8B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Assurance: ${userData['assurance']?['type'] ?? 'Non spécifié'}',
                        style: const TextStyle(
                          color: Color(0xFF0D8B8B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if ((userData['allergies'] as List?)?.isNotEmpty ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Allergies',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations personnelles
          _buildInfoCard([
            _buildInfoItem(
              Icons.person,
              'Nom complet',
              '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Age',
              '${userData['age']?.toString() ?? '0'} ans',
            ),
            _buildInfoItem(
              Icons.male,
              'Sexe',
              userData['sexe'] ?? 'Non spécifié',
            ),
            _buildInfoItem(
              Icons.location_on,
              'Adresse',
              userData['adresse'] ?? 'Non spécifiée',
            ),
          ], sectionTitle: 'Informations personnelles'),

          const SizedBox(height: 20),

          // Coordonnées
          _buildInfoCard([
            _buildInfoItem(
              Icons.phone,
              'Téléphone',
              userData['telephone'] ?? 'Non spécifié',
            ),
            _buildInfoItem(
              Icons.email,
              'Email',
              userData['email'] ?? 'Non spécifié',
            ),
          ], sectionTitle: 'Coordonnées'),

          const SizedBox(height: 20),

          // Informations d'assurance
          _buildInfoCard([
            _buildInfoItem(
              Icons.medical_services,
              'Type d\'assurance',
              userData['assurance']?['type'] ?? 'Non spécifié',
            ),
            _buildInfoItem(
              Icons.credit_card,
              'Numéro d\'assuré',
              userData['assurance']?['numero'] ?? 'Non spécifié',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Validité',
              userData['assurance']?['validite'] ?? 'Non spécifiée',
            ),
          ], sectionTitle: 'Assurance médicale'),

          const SizedBox(height: 20),

          // Compte
          _buildInfoCard([
            _buildInfoItem(
              Icons.person_outline,
              'Role',
              userData['role'] ?? 'Non spécifié',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Créé le',
              _formatTimestamp(userData['createdAt'] as Timestamp?),
            ),
          ], sectionTitle: 'Compte'),

          const SizedBox(height: 20),

          // Options de confidentialité
          _buildPrivacyOptions(),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Non spécifié';
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy à HH:mm', 'fr_FR').format(date);
  }

  // Widget pour le contenu de l'onglet médical
  Widget _buildMedicalTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0D8B8B),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        
        // Initialize medical data if not exists
        if (!userData.containsKey('allergies') ||
            !userData.containsKey('maladiesChroniquer') ||
            !userData.containsKey('traitementsCourants')) {
          // Initialize the fields if they don't exist
          FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .set({
                'allergies': userData['allergies'] ?? [],
                'maladiesChroniquer': userData['maladiesChroniquer'] ?? [],
                'traitementsCourants': userData['traitementsCourants'] ?? [],
              }, SetOptions(merge: true));
        }

        final List<dynamic> allergies = List.from(userData['allergies'] ?? []);
        final List<dynamic> maladiesChroniquer = List.from(userData['maladiesChroniquer'] ?? []);
        final List<dynamic> traitementsCourants = List.from(userData['traitementsCourants'] ?? []);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Allergies
              _buildSectionTitle('Allergies'),
              _buildListCard(
                allergies.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Aucune allergie enregistrée',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ]
                    : allergies.map<Widget>((allergy) {
                        return _buildMedicalItem(
                          Icons.dangerous,
                          allergy.toString(),
                          color: Colors.red,
                        );
                      }).toList(),
                onAddPressed: () {
                  _addAllergy();
                },
              ),

              const SizedBox(height: 20),

              // Maladies chroniques
              _buildSectionTitle('Maladies chroniques'),
              _buildListCard(
                maladiesChroniquer.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Aucune maladie chronique enregistrée',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ]
                    : maladiesChroniquer.map<Widget>((disease) {
                        return _buildMedicalItem(
                          Icons.monitor_heart,
                          disease.toString(),
                          color: Colors.orange,
                        );
                      }).toList(),
                onAddPressed: () {
                  _addChronicDisease();
                },
              ),

              const SizedBox(height: 20),

              // Traitements en cours
              _buildSectionTitle('Traitements en cours'),
              if (traitementsCourants.isEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucun traitement en cours',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: traitementsCourants.map<Widget>((treatment) {
                    return _buildTreatmentCard(
                      treatment['nom'] ?? '',
                      treatment['dosage'] ?? '',
                      treatment['frequence'] ?? '',
                    );
                  }).toList(),
                ),

              // Bouton pour ajouter un traitement
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _addTreatment();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un traitement'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D8B8B),
                    side: const BorderSide(color: Color(0xFF0D8B8B)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Carnet de vaccination
              _buildSectionTitle('Carnet de vaccination'),
              _buildVaccinationCard(),
            ],
          ),
        );
      },
    );
  }

  // Ajouter une allergie
  void _addAllergy() {
    final TextEditingController allergyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une allergie'),
          content: TextField(
            controller: allergyController,
            decoration: const InputDecoration(
              hintText: 'Nom de l\'allergie',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (allergyController.text.isNotEmpty) {
                  try {
                    final userDoc = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser?.uid);
                    
                    await userDoc.update({
                      'allergies': FieldValue.arrayUnion([allergyController.text])
                    });
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Allergie ajoutée avec succès'),
                          backgroundColor: Color(0xFF0D8B8B),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Ajouter une maladie chronique
  void _addChronicDisease() {
    final TextEditingController diseaseController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une maladie chronique'),
          content: TextField(
            controller: diseaseController,
            decoration: const InputDecoration(
              hintText: 'Nom de la maladie',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (diseaseController.text.isNotEmpty) {
                  try {
                    final userDoc = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser?.uid);
                    
                    await userDoc.update({
                      'maladiesChroniquer': FieldValue.arrayUnion([diseaseController.text])
                    });
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Maladie chronique ajoutée avec succès'),
                          backgroundColor: Color(0xFF0D8B8B),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Ajouter un traitement
  void _addTreatment() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un traitement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Nom du médicament',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  hintText: 'Dosage (ex: 100mg)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  hintText: 'Fréquence (ex: 2 fois par jour)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty &&
                    frequencyController.text.isNotEmpty) {
                  try {
                    final treatment = {
                      'nom': nameController.text,
                      'dosage': dosageController.text,
                      'frequence': frequencyController.text,
                    };

                    final userDoc = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser?.uid);
                    
                    await userDoc.update({
                      'traitementsCourants': FieldValue.arrayUnion([treatment])
                    });
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Traitement ajouté avec succès'),
                          backgroundColor: Color(0xFF0D8B8B),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Onglet Documents
  Widget _buildDocumentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bouton d'ajout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes documents médicaux',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF0D8B8B)),
                onPressed: () {
                  // Ajouter un document
                  _showAddDocumentOptions();
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Catégories de documents
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDocumentCategoryChip('Tous', isSelected: true),
                _buildDocumentCategoryChip('Ordonnances'),
                _buildDocumentCategoryChip('Résultats d\'analyses'),
                _buildDocumentCategoryChip('Radiographies'),
                _buildDocumentCategoryChip('Autres'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Liste des documents
          Expanded(
            child: ListView(
              children: [
                _buildDocumentCard(
                  'Ordonnance - Dr. Karim Alami',
                  '10/04/2025',
                  'Ordonnance',
                  Icons.description,
                ),
                _buildDocumentCard(
                  'Résultats analyse de sang',
                  '05/04/2025',
                  'Résultats d\'analyses',
                  Icons.science,
                ),
                _buildDocumentCard(
                  'Radiographie thorax',
                  '28/03/2025',
                  'Radiographies',
                  Icons.image,
                ),
                _buildDocumentCard(
                  'Certificat médical',
                  '15/03/2025',
                  'Autres',
                  Icons.file_present,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D8B8B),
        ),
      ),
    );
  }

  // Widget pour les cartes d'information
  Widget _buildInfoCard(List<Widget> children, {required String sectionTitle}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF0D8B8B),
                    size: 20,
                  ),
                  onPressed: () => _showEditSectionDialog(sectionTitle),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue pour éditer une section
  void _showEditSectionDialog(String section) {
    Map<String, TextEditingController> controllers = {};
    List<String> fields = [];

    // Définir les champs à éditer selon la section
    switch (section) {
      case 'Informations personnelles':
        fields = ['Nom complet', 'Age', 'Sexe', 'Adresse'];
        break;
      case 'Coordonnées':
        fields = ['Téléphone', 'Email'];
        break;
      case 'Contact d\'urgence':
        fields = ['Nom', 'Relation', 'Téléphone'];
        break;
      case 'Assurance médicale':
        fields = ['Type d\'assurance', 'Numéro d\'assuré', 'Validité'];
        break;
      case 'Compte':
        fields = ['Role'];
        break;
    }

    // Créer les contrôleurs pour chaque champ
    for (var field in fields) {
      controllers[field] = TextEditingController();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Modifier $section',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...fields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controllers[field],
                    decoration: InputDecoration(
                      labelText: field,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF0D8B8B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Préparer les données à mettre à jour
                        Map<String, dynamic> updateData = {};
                        
                        // Convertir les champs selon la section
                        switch (section) {
                          case 'Informations personnelles':
                            final nameParts = controllers['Nom complet']?.text.split(' ');
                            if (nameParts != null && nameParts.isNotEmpty) {
                              updateData['prenom'] = nameParts.first;
                              if (nameParts.length > 1) {
                                updateData['nom'] = nameParts.sublist(1).join(' ');
                              }
                            }
                            updateData['age'] = int.tryParse(controllers['Age']?.text ?? '') ?? 0;
                            updateData['sexe'] = controllers['Sexe']?.text;
                            updateData['adresse'] = controllers['Adresse']?.text;
                            break;
                          case 'Coordonnées':
                            updateData['telephone'] = controllers['Téléphone']?.text;
                            updateData['email'] = controllers['Email']?.text;
                            break;
                          case 'Contact d\'urgence':
                            updateData['urgence'] = {
                              'nom': controllers['Nom']?.text,
                              'relation': controllers['Relation']?.text,
                              'telephone': controllers['Téléphone']?.text,
                            };
                            break;
                          case 'Assurance médicale':
                            updateData['assurance'] = {
                              'type': controllers['Type d\'assurance']?.text,
                              'numero': controllers['Numéro d\'assuré']?.text,
                              'validite': controllers['Validité']?.text,
                            };
                            break;
                        }

                        // Mettre à jour Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser?.uid)
                            .update(updateData);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Modifications enregistrées avec succès'),
                              backgroundColor: Color(0xFF0D8B8B),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la sauvegarde: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D8B8B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget pour les éléments d'information
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF0D8B8B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les options de confidentialité
  Widget _buildPrivacyOptions() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchOption(
              'Partager mes données médicales avec mes médecins',
              true,
                  (value) {},
            ),
            const Divider(),
            _buildSwitchOption(
              'Recevoir des notifications de rappel de rendez-vous',
              true,
                  (value) {},
            ),
            const Divider(),
            _buildSwitchOption(
              'Recevoir des notifications de rappel de médicaments',
              true,
                  (value) {},
            ),
            const Divider(),
            _buildSwitchOption(
              'Autoriser l\'accès à ma localisation',
              false,
                  (value) {},
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les options avec interrupteur
  Widget _buildSwitchOption(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D8B8B),
          ),
        ],
      ),
    );
  }

  // Widget pour les cartes de liste (allergies, maladies)
  Widget _buildListCard(List<Widget> items, {required VoidCallback onAddPressed}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...items,
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Aucun élément à afficher',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D8B8B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les éléments médicaux (allergies, maladies)
  Widget _buildMedicalItem(IconData icon, String text, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Colors.grey,
            ),
            onPressed: () {
              // Supprimer l'élément
            },
          ),
        ],
      ),
    );
  }

  // Widget pour les cartes de traitement
  Widget _buildTreatmentCard(String name, String dosage, String frequency) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D8B8B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medication,
                color: Color(0xFF0D8B8B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Dosage: $dosage',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fréquence: $frequency',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Afficher les options
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour le carnet de vaccination
  Widget _buildVaccinationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Carnet de vaccination à jour',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () {
                    // Voir le carnet de vaccination
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les catégories de documents
  Widget _buildDocumentCategoryChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Filtrer les documents
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF0D8B8B).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF0D8B8B) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget pour les cartes de document
  Widget _buildDocumentCard(String title, String date, String category, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D8B8B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0D8B8B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date: $date',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Catégorie: $category',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Télécharger le document
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialogue pour l'édition du profil
  void _showEditProfileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifier le profil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditOption(
                'Modifier les informations personnelles',
                Icons.person,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran d'édition des informations personnelles
                },
              ),
              _buildEditOption(
                'Modifier les coordonnées',
                Icons.phone,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran d'édition des coordonnées
                },
              ),
              _buildEditOption(
                'Modifier le contact d\'urgence',
                Icons.emergency,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran d'édition du contact d'urgence
                },
              ),
              _buildEditOption(
                'Modifier les informations d\'assurance',
                Icons.medical_services,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran d'édition des informations d'assurance
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialogue pour les paramètres
  void _showSettingsOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditOption(
                'Confidentialité et sécurité',
                Icons.security,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran de confidentialité
                },
              ),
              _buildEditOption(
                'Notifications',
                Icons.notifications,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran de notifications
                },
              ),
              _buildEditOption(
                'Changer de langue',
                Icons.language,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran de langue
                },
              ),
              _buildEditOption(
                'Aide et Support',
                Icons.help,
                    () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran d'aide
                },
              ),
              _buildEditOption(
                'Se déconnecter',
                Icons.logout,
                    () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Supprime toutes les données sauvegardées

                  Navigator.pushReplacementNamed(context, '/login'); // Redirige vers la page de login
                },
                color: Colors.red,
              ),

            ],
          ),
        );
      },
    );
  }

  // Dialogue pour ajouter un document
  void _showAddDocumentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter un document',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditOption(
                'Prendre une photo',
                Icons.camera_alt,
                    () {
                  Navigator.pop(context);
                  // Ouvrir la caméra
                },
              ),
              _buildEditOption(
                'Choisir depuis la galerie',
                Icons.photo_library,
                    () {
                  Navigator.pop(context);
                  // Ouvrir la galerie
                },
              ),
              _buildEditOption(
                'Importer un fichier',
                Icons.file_present,
                    () {
                  Navigator.pop(context);
                  // Ouvrir le gestionnaire de fichiers
                },
              ),
              _buildEditOption(
                'Scanner un document',
                Icons.document_scanner,
                    () {
                  Navigator.pop(context);
                  // Ouvrir le scanner
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget pour les options d'édition
  Widget _buildEditOption(
      String title,
      IconData icon,
      VoidCallback onTap, {
        Color color = const Color(0xFF0D8B8B),
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}