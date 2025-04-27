import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // Données fictives du patient
  final Map<String, dynamic> _patientData = {
    'photo': 'assets/images/profile.jpeg',
    'nom': 'Alaoui',
    'prenom': 'Ahmed',
    'dateNaissance': '15/05/1985',
    'sexe': 'Homme',
    'adresse': '123 Avenue Mohammed V, Casablanca',
    'telephone': '0612345678',
    'email': 'ahmed.alaoui@gmail.com',
    'groupeSanguin': 'A+',
    'allergies': ['Pénicilline', 'Arachides'],
    'maladiesChroniquer': ['Diabète type 2', 'Hypertension'],
    'traitementsCourants': [
      {'nom': 'Metformine', 'dosage': '500mg', 'frequence': '2 fois par jour'},
      {'nom': 'Lisinopril', 'dosage': '10mg', 'frequence': '1 fois par jour'},
    ],
    'contactUrgence': {
      'nom': 'Alaoui Fatima',
      'relation': 'Épouse',
      'telephone': '0612345679',
    },
    'assurance': {
      'type': 'CNOPS',
      'numero': 'CN123456789',
      'validite': '31/12/2025',
    },
    'historiqueConsultations': [
      {
        'date': '10/04/2025',
        'medecin': 'Dr. Karim Alami',
        'specialite': 'Cardiologue',
        'motif': 'Contrôle annuel',
      },
      {
        'date': '15/03/2025',
        'medecin': 'Dr. Amina Benali',
        'specialite': 'Endocrinologue',
        'motif': 'Suivi diabète',
      },
    ],
  };

  // Index de l'onglet actif
  int _currentTabIndex = 0;

  // Liste des onglets
  final List<String> _tabs = [
    'Profil',
    'Médical',
    'Documents',
    'Rendez-vous',
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
              // Naviguer vers l'écran d'édition du profil
              _showEditProfileOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF0D8B8B)),
            onPressed: () {
              // Naviguer vers les paramètres
              _showSettingsOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec photo et informations de base
          _buildProfileHeader(),

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
                _buildProfileTab(),
                _buildMedicalTab(),
                _buildDocumentsTab(),
                _buildAppointmentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // En-tête du profil avec photo et informations de base
  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Photo de profil
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: _patientData['photo'] != null && _patientData['photo'].isNotEmpty
                ? AssetImage(_patientData['photo']) // photo depuis assets
                : null, // sinon pas de backgroundImage
            child: _patientData['photo'] == null || _patientData['photo'].isEmpty
                ? const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            )
                : null, // Pas d'icône si image présente
          ),

          const SizedBox(width: 20),

          // Informations de base
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_patientData['prenom']} ${_patientData['nom']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Né le ${_patientData['dateNaissance']} (${_calculateAge(_patientData['dateNaissance'])} ans)',
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
                        'Groupe ${_patientData['groupeSanguin']}',
                        style: const TextStyle(
                          color: Color(0xFF0D8B8B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
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

  // Onglet Profil
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations personnelles
          _buildSectionTitle('Informations personnelles'),
          _buildInfoCard([
            _buildInfoItem(
              Icons.person,
              'Nom complet',
              '${_patientData['prenom']} ${_patientData['nom']}',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Date de naissance',
              _patientData['dateNaissance'],
            ),
            _buildInfoItem(
              Icons.male,
              'Sexe',
              _patientData['sexe'],
            ),
            _buildInfoItem(
              Icons.location_on,
              'Adresse',
              _patientData['adresse'],
            ),
          ]),

          const SizedBox(height: 20),

          // Coordonnées
          _buildSectionTitle('Coordonnées'),
          _buildInfoCard([
            _buildInfoItem(
              Icons.phone,
              'Téléphone',
              _patientData['telephone'],
            ),
            _buildInfoItem(
              Icons.email,
              'Email',
              _patientData['email'],
            ),
          ]),

          const SizedBox(height: 20),

          // Contact d'urgence
          _buildSectionTitle('Contact d\'urgence'),
          _buildInfoCard([
            _buildInfoItem(
              Icons.person_pin,
              'Nom',
              _patientData['contactUrgence']['nom'],
            ),
            _buildInfoItem(
              Icons.family_restroom,
              'Relation',
              _patientData['contactUrgence']['relation'],
            ),
            _buildInfoItem(
              Icons.phone,
              'Téléphone',
              _patientData['contactUrgence']['telephone'],
            ),
          ]),

          const SizedBox(height: 20),

          // Informations d'assurance
          _buildSectionTitle('Assurance médicale'),
          _buildInfoCard([
            _buildInfoItem(
              Icons.medical_services,
              'Type d\'assurance',
              _patientData['assurance']['type'],
            ),
            _buildInfoItem(
              Icons.credit_card,
              'Numéro d\'assuré',
              _patientData['assurance']['numero'],
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Validité',
              _patientData['assurance']['validite'],
            ),
          ]),

          const SizedBox(height: 20),

          // Options de confidentialité
          _buildSectionTitle('Confidentialité et sécurité'),
          _buildPrivacyOptions(),
        ],
      ),
    );
  }

  // Onglet Médical
  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Allergies
          _buildSectionTitle('Allergies'),
          _buildListCard(
            _patientData['allergies'].map<Widget>((allergy) {
              return _buildMedicalItem(
                Icons.dangerous,
                allergy,
                color: Colors.red,
              );
            }).toList(),
            onAddPressed: () {
              // Ajouter une allergie
            },
          ),

          const SizedBox(height: 20),

          // Maladies chroniques
          _buildSectionTitle('Maladies chroniques'),
          _buildListCard(
            _patientData['maladiesChroniquer'].map<Widget>((disease) {
              return _buildMedicalItem(
                Icons.monitor_heart,
                disease,
                color: Colors.orange,
              );
            }).toList(),
            onAddPressed: () {
              // Ajouter une maladie chronique
            },
          ),

          const SizedBox(height: 20),

          // Traitements en cours
          _buildSectionTitle('Traitements en cours'),
          Column(
            children: _patientData['traitementsCourants'].map<Widget>((treatment) {
              return _buildTreatmentCard(
                treatment['nom'],
                treatment['dosage'],
                treatment['frequence'],
              );
            }).toList(),
          ),

          // Bouton pour ajouter un traitement
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton.icon(
              onPressed: () {
                // Ajouter un traitement
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

  // Onglet Rendez-vous
  Widget _buildAppointmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation entre rendez-vous à venir et passés
          Row(
            children: [
              Expanded(
                child: _buildAppointmentTabButton(
                  'À venir',
                  isSelected: true,
                ),
              ),
              Expanded(
                child: _buildAppointmentTabButton(
                  'Passés',
                  isSelected: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Liste des rendez-vous
          Expanded(
            child: ListView(
              children: [
                _buildAppointmentCard(
                  'Dr. Karim Alami',
                  'Cardiologue',
                  '24 Avril, 2025',
                  '10:30',
                  status: 'Confirmé',
                  isUpcoming: true,
                ),
                _buildAppointmentCard(
                  'Dr. Amina Benali',
                  'Endocrinologue',
                  '15 Mai, 2025',
                  '14:00',
                  status: 'En attente',
                  isUpcoming: true,
                ),
              ],
            ),
          ),

          // Bouton pour prendre un nouveau rendez-vous
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Naviguer vers l'écran de prise de rendez-vous
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau rendez-vous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
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

  // Widget pour les boutons d'onglet de rendez-vous
  Widget _buildAppointmentTabButton(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected
                ? const Color(0xFF0D8B8B)
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0D8B8B) : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget pour les cartes de rendez-vous
  Widget _buildAppointmentCard(
      String doctorName,
      String specialty,
      String date,
      String time, {
        required String status,
        required bool isUpcoming,
      }) {
    Color statusColor;
    if (status == 'Confirmé') {
      statusColor = Colors.green;
    } else if (status == 'En attente') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      color: Color(0xFF0D8B8B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF0D8B8B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Annuler le rendez-vous
                    },
                    child: const Text('Annuler'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Modifier le rendez-vous
                    },
                    child: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D8B8B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Fonction pour calculer l'âge à partir de la date de naissance
  int _calculateAge(String birthDateStr) {
    final parts = birthDateStr.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    final birthDate = DateTime(year, month, day);
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    // Vérifier si l'anniversaire est déjà passé cette année
    final currentBirthday = DateTime(today.year, birthDate.month, birthDate.day);
    if (today.isBefore(currentBirthday)) {
      age--;
    }

    return age;
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