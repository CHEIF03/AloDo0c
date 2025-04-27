import 'package:flutter/material.dart';
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
    'Cardiologue',
    'Dermatologue',
    'Pédiatre',
    'Psychiatre',
    'Gynécologue',
    'Neurologue',
    'Ophtalmologue',
    'ORL',
    'Dentiste'
  ];

  // Liste de médecins (simulation de données)
  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Karim Alami',
      'speciality': 'Cardiologue',
      'rating': 4.9,
      'reviews': 128,
      'distance': 2.5,
      'available': true,
      'fee': 400,
      'image': 'assets/images/med1.jpg',
    },
    {
      'name': 'Dr. Amina Benali',
      'speciality': 'Dermatologue',
      'rating': 4.8,
      'reviews': 96,
      'distance': 3.2,
      'available': true,
      'fee': 350,
      'image': 'assets/images/doc8.jpeg',
    },
    {
      'name': 'Dr. Mehdi Rami',
      'speciality': 'Pédiatre',
      'rating': 4.7,
      'reviews': 114,
      'distance': 1.8,
      'available': false,
      'fee': 300,
      'image': 'assets/images/med2.png',
    },
    {
      'name': 'Dr. Fatima Zahra',
      'speciality': 'Gynécologue',
      'rating': 4.9,
      'reviews': 157,
      'distance': 4.1,
      'available': true,
      'fee': 450,
      'image': 'assets/images/doc6.jpeg',
    },
    {
      'name': 'Dr. Youssef Tazi',
      'speciality': 'Neurologue',
      'rating': 4.6,
      'reviews': 82,
      'distance': 3.7,
      'available': true,
      'fee': 500,
      'image': 'assets/images/med3.jpg',
    },
    {
      'name': 'Dr. Salma Idrissi',
      'speciality': 'Dentiste',
      'rating': 4.8,
      'reviews': 135,
      'distance': 2.2,
      'available': false,
      'fee': 380,
      'image': 'assets/images/doc7.jpeg',
    },
  ];

  // Liste de médecins filtrée
  List<Map<String, dynamic>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = List.from(_doctors);

    // Ajouter un écouteur au contrôleur de recherche
    _searchController.addListener(() {
      _filterDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour filtrer les médecins
  void _filterDoctors() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();

      _filteredDoctors = _doctors.where((doctor) {
        // Filtrer par spécialité si une spécialité est sélectionnée
        bool matchesSpeciality = _selectedSpeciality == 'Tous' ||
            doctor['speciality'] == _selectedSpeciality;

        // Filtrer par le texte de recherche (nom ou spécialité)
        bool matchesSearch = searchQuery.isEmpty ||
            doctor['name'].toLowerCase().contains(searchQuery) ||
            doctor['speciality'].toLowerCase().contains(searchQuery);

        return matchesSpeciality && matchesSearch;
      }).toList();
    });
  }

  // Mettre à jour le filtre de spécialité
  void _updateSpecialityFilter(String speciality) {
    setState(() {
      _selectedSpeciality = speciality;
      _filterDoctors();
    });
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
              // Afficher les options de filtrage avancées
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
                              _updateSpecialityFilter(speciality);
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

          // Nombre de résultats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredDoctors.length} médecins trouvés',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Trier par: ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Popularité',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D8B8B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF0D8B8B),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des médecins
          Expanded(
            child: _filteredDoctors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // État vide (aucun médecin trouvé)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun médecin trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Carte affichant les informations d'un médecin
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
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
                    child: doctor['image'] != null
                        ? Image.asset(
                      doctor['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        );
                      },
                    )
                        : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
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
                        doctor['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor['speciality'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Évaluation
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor['reviews']} avis)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Distance
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF0D8B8B),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor['distance']} km',
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
                    color: doctor['available']
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor['available'] ? 'Disponible' : 'Occupé',
                    style: TextStyle(
                      color: doctor['available'] ? Colors.green : Colors.red,
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
                      '${doctor['fee']} DH',
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
                    // Navigation vers la page de détail du médecin
                    _navigateToDoctorDetails(context, doctor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8B8B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Prendre RDV'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue des options de filtrage
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

              const SizedBox(height: 16),

              const Text(
                'Disponibilité',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Aujourd\'hui'),
                    selected: true,
                    onSelected: (bool selected) {},
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: const Color(0xFF0D8B8B).withOpacity(0.2),
                    labelStyle: const TextStyle(
                      color: Color(0xFF0D8B8B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Demain'),
                    selected: false,
                    onSelected: (bool selected) {},
                    backgroundColor: Colors.grey.shade100,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Cette semaine'),
                    selected: false,
                    onSelected: (bool selected) {},
                    backgroundColor: Colors.grey.shade100,
                  ),
                ],
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

  // Naviguer vers la page de détails du médecin
  void _navigateToDoctorDetails(BuildContext context, Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }
}