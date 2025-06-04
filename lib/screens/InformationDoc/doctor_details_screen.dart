import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  // Variables pour gérer la sélection du jour et de l'heure
  String _selectedDay = 'Lun';
  String _selectedDate = '24';
  String _selectedTime = '09:00';

  // Liste des jours disponibles
  final List<Map<String, String>> _availableDays = [
    {'day': 'Lun', 'date': '24'},
    {'day': 'Mar', 'date': '25'},
    {'day': 'Mer', 'date': '26'},
    {'day': 'Jeu', 'date': '27'},
    {'day': 'Ven', 'date': '28'},
    {'day': 'Sam', 'date': '29'},
    {'day': 'Dim', 'date': '30'},
  ];

  // Liste des créneaux horaires disponibles
  final List<String> _availableTimes = [
    '09:00', '10:00', '11:00', '12:00',
    '14:00', '15:00', '16:00', '17:00'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _availableDays[0]['day']!;
    _selectedDate = _availableDays[0]['date']!;
    _selectedTime = _availableTimes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D8B8B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du médecin',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF0D8B8B)),
            onPressed: () {
              // Ajouter aux favoris
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ajouté aux favoris'),
                  backgroundColor: Color(0xFF0D8B8B),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF0D8B8B)),
            onPressed: () {
              // Partager le profil du médecin
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage du profil en cours...'),
                  backgroundColor: Color(0xFF0D8B8B),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec photo et informations
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image du médecin
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.doctor['image'] != null
                          ? Image.asset(
                        widget.doctor['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          );
                        },
                      )
                          : const Icon(
                        Icons.person,
                        size: 60,
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
                          widget.doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor['speciality'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
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
                              widget.doctor['rating'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.doctor['reviews']} avis)',
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
                ],
              ),
            ),

            // Badge de disponibilité
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.doctor['available']
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.doctor['available']
                      ? 'Disponible aujourd\'hui'
                      : 'Prochain rendez-vous disponible demain',
                  style: TextStyle(
                    color: widget.doctor['available'] ? Colors.green : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistiques du médecin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatItem(
                    icon: Icons.work,
                    value: '8+',
                    label: 'Années d\'expérience',
                  ),
                  _buildStatItem(
                    icon: Icons.people,
                    value: '2500+',
                    label: 'Patients',
                  ),
                  _buildStatItem(
                    icon: Icons.star,
                    value: widget.doctor['rating'].toString(),
                    label: 'Évaluation',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // À propos du médecin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À propos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.doctor['name']} est un médecin ${widget.doctor['speciality'].toLowerCase()} expérimenté avec plus de 8 ans de pratique clinique. Spécialisé dans le diagnostic et le traitement des affections médicales, il propose une approche personnalisée pour chaque patient.\n\nDiplômé de la faculté de médecine de Rabat, il a complété sa formation par une spécialisation à l\'hôpital universitaire et participe régulièrement à des conférences internationales pour rester à jour sur les dernières avancées médicales.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Disponibilité - Titre
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Prendre rendez-vous',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sélection du jour
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionnez le jour',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDays.length,
                      itemBuilder: (context, index) {
                        final day = _availableDays[index]['day']!;
                        final date = _availableDays[index]['date']!;
                        final isSelected = day == _selectedDay && date == _selectedDate;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            width: 60,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D8B8B) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: !isSelected
                                  ? Border.all(color: Colors.grey.shade300)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sélection de l'heure
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionnez l\'heure',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableTimes.map((time) {
                      final isSelected = time == _selectedTime;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0D8B8B) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: !isSelected
                                ? Border.all(color: Colors.grey.shade300)
                                : null,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Adresse du cabinet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adresse du cabinet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF0D8B8B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '123 Avenue Mohammed V, Casablanca, Maroc',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Carte (simulé par un container)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Espace pour le bouton
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tarif de consultation',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${widget.doctor['fee']} DH',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                // Confirmation du rendez-vous
                _showConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirmer le rendez-vous',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogue de confirmation du rendez-vous
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirmer le rendez-vous',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D8B8B),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Médecin: '),
                    TextSpan(
                      text: widget.doctor['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Date: '),
                    TextSpan(
                      text: '$_selectedDay $_selectedDate Avril 2025',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Heure: '),
                    TextSpan(
                      text: _selectedTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Tarif: '),
                    TextSpan(
                      text: '${widget.doctor['fee']} DH',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Create the appointment
                final appointment = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'doctorName': widget.doctor['name'],
                  'specialty': widget.doctor['speciality'],
                  'date': DateTime(
                    2025,
                    4,
                    int.parse(_selectedDate),
                    int.parse(_selectedTime.split(':')[0]),
                    int.parse(_selectedTime.split(':')[1]),
                  ),
                  'status': 'confirmé',
                  'notes': '',
                  'location': widget.doctor['location'] ?? 'Cabinet médical',
                  'address': widget.doctor['address'] ?? '',
                  'phone': widget.doctor['phone'] ?? '',
                  'photo': widget.doctor['image'],
                  'requiredDocs': [
                    'Carte vitale',
                    'Pièce d\'identité',
                  ],
                  'preparation': '',
                };

                // Close the confirmation dialog
                Navigator.pop(context);
                
                // Return to the appointments screen with the new appointment
                Navigator.pop(context, appointment);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rendez-vous confirmé avec succès'),
                    backgroundColor: Color(0xFF0D8B8B),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Widget pour les statistiques
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D8B8B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0D8B8B),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}