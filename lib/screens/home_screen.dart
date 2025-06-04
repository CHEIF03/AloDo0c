import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importation des pages pour chaque onglet
import 'InformationDoc/doctors_screen.dart';  // Assurez-vous que ce chemin est correct
import 'InforamtionPatient/patient_profile_screen.dart'; // Profile de Patient
import 'rdv/appointments_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Définition de la liste des pages
  final List<Widget> _pages = [
    const HomeTab(),           // Page d'accueil
    const DoctorsScreen(),     // Page des médecins - importée depuis doctors_screen.dart
    const AppointmentsTab(),   // Page des rendez-vous
    const MessagesTab(), // Page des messages
    const PatientProfileScreen() // Profile de Patient
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AloDocLogo(height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0D8B8B)),
            onPressed: () {
              // Afficher les notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF0D8B8B)),
            onPressed: () {
              // Navigation vers l'écran de profil patient
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      // Utiliser l'index pour afficher la page sélectionnée
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            print("Navigating to tab $index"); // Pour déboguer
          });
        },
        selectedItemColor: const Color(0xFF0D8B8B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Médecins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'RDV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

// Page d'accueil (premier onglet)
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière de bienvenue
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D8B8B),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bonjour, Ahmed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Comment vous sentez-vous aujourd\'hui ?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Consultez un médecin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options rapides
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _buildServiceCard(
                color: Colors.blue[100]!,
                icon: Icons.medical_services,
                title: 'Consultation',
              ),
              _buildServiceCard(
                color: Colors.green[100]!,
                icon: Icons.local_pharmacy,
                title: 'Pharmacie',
              ),
              _buildServiceCard(
                color: Colors.orange[100]!,
                icon: Icons.science,
                title: 'Laboratoire',
              ),
              _buildServiceCard(
                color: Colors.purple[100]!,
                icon: Icons.monitor_heart,
                title: 'Urgence',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Médecins populaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Médecins populaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Naviguer vers l'onglet médecins
                },
                child: const Text(
                  'Voir tous',
                  style: TextStyle(
                    color: Color(0xFF0D8B8B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Liste de médecins
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDoctorCard(
                  name: 'Dr. Karim Alami',
                  speciality: 'Cardiologue',
                  rating: 4.9,
                ),
                _buildDoctorCard(
                  name: 'Dr. Amina Benali',
                  speciality: 'Dermatologue',
                  rating: 4.8,
                ),
                _buildDoctorCard(
                  name: 'Dr. Mehdi Rami',
                  speciality: 'Pédiatre',
                  rating: 4.7,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Rendez-vous à venir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rendez-vous à venir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Voir tous les rendez-vous
                },
                child: const Text(
                  'Voir tous',
                  style: TextStyle(
                    color: Color(0xFF0D8B8B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Carte de rendez-vous
          _buildAppointmentCard(
            doctorName: 'Dr. Karim Alami',
            specialty: 'Cardiologue',
            date: '24 Avril, 2025',
            time: '10:30',
            status: 'Confirmé',
          ),
        ],
      ),
    );
  }

  // Widget pour les cartes de service
  Widget _buildServiceCard({
    required Color color,
    required IconData icon,
    required String title,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF0D8B8B),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les cartes de médecin
  Widget _buildDoctorCard({
    required String name,
    required String speciality,
    required double rating,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            speciality,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Prendre RDV
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D8B8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(120, 30),
            ),
            child: const Text(
              'Prendre RDV',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les cartes de rendez-vous
  Widget _buildAppointmentCard({
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.calendar_today,
                color: Color(0xFF0D8B8B),
                size: 30,
              ),
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
                const SizedBox(height: 8),
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
                    const SizedBox(width: 16),
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
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D8B8B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF0D8B8B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder pour l'onglet rendez-vous
class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Vos rendez-vous',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D8B8B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Consultez et gérez tous vos rendez-vous médicaux',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32), // Espace avant le bouton
          ElevatedButton.icon(
            onPressed: () {
              // Navigation vers l'écran des rendez-vous
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('Voir mes rendez-vous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D8B8B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder pour l'onglet messages
class MessagesTab extends StatelessWidget {
  const MessagesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D8B8B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Communiquez facilement avec vos médecins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour le logo AloDoc
class AloDocLogo extends StatelessWidget {
  final double height;

  const AloDocLogo({Key? key, this.height = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_doc.png',
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          padding: const EdgeInsets.all(8),
          child: const Center(
            child: Text(
              'AloDoc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D8B8B),
              ),
            ),
          ),
        );
      },
    );
  }
}