import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_details_screen.dart';// Importation de la page de détails


class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  // Contrôleur pour la recherche
  final TextEditingController _searchController = TextEditingController();

  // Filtre sélectionné
  String _selectedSpeciality = 'Tous';

  // Liste de spécialités pour le filtre
  final List<String> _specialities = [
    'Tous',
    'Médecine générale',
    'Cardiologie',
    'Dermatologie',
    'Pédiatrie',
    'Psychiatrie',
    'Gynécologie',
    'Neurologie',
    'Ophtalmologie',
    'ORL'
  ];

  // Liste d'images de profil aléatoires
  final List<String> _profileImages = [
    'assets/images/med1.jpg',
    'assets/images/med2.png',
    'assets/images/med3.jpg',
    'assets/images/med4.jpeg',
    'assets/images/doc5.jpeg',
    'assets/images/doc6.jpeg',
    'assets/images/doc7.jpeg',
    'assets/images/doc8.jpeg',
  ];

  // Stream des médecins filtrés
  Stream<QuerySnapshot> _getDoctorsStream() {
    return FirebaseFirestore.instance
        .collection('doctors')
        .where('isApproved', isEqualTo: true)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  // Fonction pour filtrer les médecins
  List<DocumentSnapshot> _filterDoctors(List<DocumentSnapshot> doctors) {
    String searchQuery = _searchController.text.toLowerCase();

    return doctors.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Filtrer par spécialité si une spécialité est sélectionnée
      bool matchesSpeciality = _selectedSpeciality == 'Tous' ||
          data['specialite'] == _selectedSpeciality;

      // Filtrer par le texte de recherche (nom, prénom ou spécialité)
      bool matchesSearch = searchQuery.isEmpty ||
          '${data['prenom']} ${data['nom']}'.toLowerCase().contains(searchQuery) ||
          data['specialite'].toString().toLowerCase().contains(searchQuery);

      return matchesSpeciality && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Médecins',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF0D8B8B)),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un médecin ou une spécialité',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D8B8B)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // Filtres de spécialités
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialities.length,
                    itemBuilder: (context, index) {
                      final speciality = _specialities[index];
                      final isSelected = speciality == _selectedSpeciality;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(speciality),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSpeciality = speciality;
                              });
                            }
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: const Color(0xFF0D8B8B).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF0D8B8B) : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des médecins
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDoctorsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0D8B8B),
                    ),
                  );
                }

                List<DocumentSnapshot> filteredDoctors = _filterDoctors(snapshot.data!.docs);

                if (filteredDoctors.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> doctorData = filteredDoctors[index].data() as Map<String, dynamic>;
                    // Assigner une image aléatoire au médecin
                    String randomImage = _profileImages[index % _profileImages.length];
                    return _buildDoctorCard(doctorData, randomImage);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, String imageAsset) {
    // Calculer une note aléatoire entre 4.0 et 5.0
    double rating = 4.0 + (DateTime.now().millisecondsSinceEpoch % 10) / 10;
    // Générer un nombre aléatoire d'avis entre 50 et 200
    int reviews = 50 + (DateTime.now().millisecondsSinceEpoch % 150);
    // Générer un tarif aléatoire entre 300 et 600 DH
    int fee = 300 + (DateTime.now().millisecondsSinceEpoch % 300);
    // Générer une distance aléatoire entre 1 et 10 km
    double distance = 1.0 + (DateTime.now().millisecondsSinceEpoch % 90) / 10;

    Map<String, dynamic> doctorDetails = {
      ...doctor,
      'name': '${doctor['titre']} ${doctor['prenom']} ${doctor['nom']}',
      'speciality': doctor['specialite'],
      'rating': rating,
      'reviews': reviews,
      'fee': fee,
      'distance': distance,
      'available': true,
      'image': imageAsset,
      'location': 'Cabinet médical - ${doctor['ville']}',
      'phone': doctor['telephoneCabinet'],
      'address': doctor['ville'],
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Partie supérieure avec image et informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du médecin
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations sur le médecin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorDetails['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctorDetails['speciality'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews avis)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF0D8B8B),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Badge de disponibilité
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Disponible',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.grey[200],
            height: 1,
          ),

          // Partie inférieure avec tarif et bouton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tarif de consultation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tarif de consultation',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$fee DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0D8B8B),
                      ),
                    ),
                  ],
                ),

                // Bouton de prise de rendez-vous
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailsScreen(doctor: doctorDetails),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8B8B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),  
                  child: const Text('Prendre RDV 1'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun médecin trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Color(0xFF0D8B8B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Options de filtrage
              const Text(
                'Distance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: 5,
                min: 1,
                max: 10,
                divisions: 9,
                label: '5 km',
                activeColor: const Color(0xFF0D8B8B),
                onChanged: (value) {},
              ),

              const SizedBox(height: 20),

              // Bouton Appliquer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8B8B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Appliquer les filtres',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}