import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

// Import components
import 'InformationDoc/doctor_details_screen.dart';
import 'home/home_tab.dart';
import 'InformationDoc/doctors_screen.dart';
import 'rdv/appointments_screen.dart';
import 'chat/chat_screen.dart';
import 'InforamtionPatient/patient_profile_screen.dart';
import 'widgets/alodoc_logo.dart';

// Main HomeScreen widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),           // Page d'accueil
    const DoctorsScreen(),     // Page des médecins
    const AppointmentsTab(),   // Page des rendez-vous
    const MessagesTab(),       // Page des messages
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
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

  // Liste d'images de profil aléatoires
  static const List<String> _profileImages = [
    'assets/images/med1.jpg',
    'assets/images/med2.png',
    'assets/images/med3.jpg',
    'assets/images/med4.jpeg',
    'assets/images/doc5.jpeg',
    'assets/images/doc6.jpeg',
    'assets/images/doc7.jpeg',
    'assets/images/doc8.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière de bienvenue avec le nom de l'utilisateur
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D8B8B),
                  ),
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final String userName = userData != null 
                  ? '${userData['prenom']} ${userData['nom']}'
                  : 'Utilisateur';

              return Container(
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
                        children: [
                          Text(
                            'Bonjour, $userName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Comment vous sentez-vous aujourd\'hui ?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
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
              );
            },
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorsScreen(),
                    ),
                  );
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

          // Liste de médecins populaires depuis Firebase
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where('isApproved', isEqualTo: true)
                  .where('isPopulaire', isEqualTo: true)
                  .limit(5)
                  .snapshots(),
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aucun médecin populaire trouvé'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doctor = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    // Assigner une image aléatoire au médecin
                    String randomImage = _profileImages[index % _profileImages.length];
                    // Calculer une note aléatoire entre 4.0 et 5.0
                    double rating = 4.0 + (index % 10) / 10;

                    return _buildDoctorCard(
                      name: '${doctor['titre']} ${doctor['prenom']} ${doctor['nom']}',
                      speciality: doctor['specialite'],
                      rating: rating,
                      image: randomImage,
                      doctor: doctor,
                      context: context,
                    );
                  },
                );
              },
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

  // Widget modifié pour les cartes de médecin
  Widget _buildDoctorCard({
    required String name,
    required String speciality,
    required double rating,
    required String image,
    required Map<String, dynamic> doctor,
    required BuildContext context,
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
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            speciality,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Préparer les détails du médecin pour la navigation
              Map<String, dynamic> doctorDetails = {
                ...doctor,
                'name': name,
                'speciality': speciality,
                'rating': rating,
                'image': image,
                'reviews': 50 + (DateTime.now().millisecondsSinceEpoch % 150),
                'fee': 300 + (DateTime.now().millisecondsSinceEpoch % 300),
                'distance': 1.0 + (DateTime.now().millisecondsSinceEpoch % 90) / 10,
                'available': true,
                'location': 'Cabinet médical - ${doctor['ville']}',
              };

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

  // Function to make a phone call
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    // Format the phone number to remove any spaces or special characters
    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: formattedNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'appeler le numéro: $formattedNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'appel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
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
              'Connectez-vous pour voir vos rendez-vous',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D8B8B),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: currentUser.uid)
          .snapshots(),
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

        final appointments = snapshot.data?.docs ?? [];
        
        // Sort appointments in memory instead of in the query
        appointments.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = (aData['date'] as Timestamp).toDate();
          final bDate = (bData['date'] as Timestamp).toDate();
          return aDate.compareTo(bDate);
        });

        if (appointments.isEmpty) {
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
                  'Aucun rendez-vous',
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
                    'Vous n\'avez pas encore de rendez-vous programmé',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Prendre un rendez-vous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8B8B),
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index].data() as Map<String, dynamic>;
            final appointmentDate = appointment['date'] as Timestamp;
            final date = appointmentDate.toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF0D8B8B).withOpacity(0.1),
                          child: const Icon(
                            Icons.medical_services,
                            color: Color(0xFF0D8B8B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['doctorName'] ?? 'Médecin non spécifié',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                appointment['specialty'] ?? 'Spécialité non spécifiée',
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
                            color: _getStatusColor(appointment['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment['status'] ?? 'En attente',
                            style: TextStyle(
                              color: _getStatusColor(appointment['status']),
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
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF0D8B8B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF0D8B8B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF0D8B8B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appointment['location'] ?? 'Emplacement non spécifié',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (appointment['status'] == 'confirmé') ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.message,
                            label: 'Message',
                            onPressed: () {
                              // Get doctor details from the appointment
                              final doctorDetails = {
                                'id': appointment['doctorId'],
                                'name': appointment['doctorName'],
                                'speciality': appointment['specialty'],
                                'photo': appointment['photo'],
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    doctor: doctorDetails,
                                    appointmentId: appointment['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.phone,
                            label: 'Appeler',
                            onPressed: () async {
                              final phoneNumber = appointment['phone'];
                              if (phoneNumber == null || phoneNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Numéro de téléphone non disponible'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Show the phone number in a dialog before making the call
                              final shouldCall = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Appeler le médecin'),
                                    content: Text('Voulez-vous appeler le $phoneNumber ?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text('Appeler'),
                                        onPressed: () => Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldCall == true && context.mounted) {
                                await _makePhoneCall(context, phoneNumber);
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.calendar_today,
                            label: 'Reprogrammer',
                            onPressed: () async {
                              // Show date picker
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF0D8B8B),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedDate != null && context.mounted) {
                                // Show time picker
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF0D8B8B),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedTime != null && context.mounted) {
                                  // Combine date and time
                                  final DateTime newDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  // Show confirmation dialog
                                  final bool? shouldReschedule = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmer la reprogrammation'),
                                        content: Text(
                                          'Voulez-vous reprogrammer ce rendez-vous pour le ${DateFormat('dd/MM/yyyy à HH:mm').format(newDateTime)} ?'
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color(0xFF0D8B8B),
                                            ),
                                            child: const Text('Confirmer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldReschedule == true && context.mounted) {
                                    try {
                                      // Update the appointment in Firestore
                                      await FirebaseFirestore.instance
                                          .collection('appointments')
                                          .doc(appointment['id'])
                                          .update({
                                        'date': Timestamp.fromDate(newDateTime),
                                        'status': 'confirmé',
                                        'rescheduledAt': FieldValue.serverTimestamp(),
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Rendez-vous reprogrammé avec succès'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Erreur lors de la reprogrammation: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.cancel,
                            label: 'Annuler',
                            onPressed: () async {
                              // Show confirmation dialog
                              final shouldCancel = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Annuler le rendez-vous'),
                                    content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Non'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Oui, annuler'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldCancel == true) {
                                try {
                                  // Update the appointment status in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(appointment['id'])
                                      .update({
                                    'status': 'annulé',
                                    'canceledAt': FieldValue.serverTimestamp(),
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Rendez-vous annulé avec succès'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur lors de l\'annulation: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'annulé':
        return Colors.red;
      case 'terminé':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF0D8B8B),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0D8B8B),
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
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous pour voir vos messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D8B8B),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: currentUser.uid)
          .snapshots(),
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

        final appointments = snapshot.data?.docs ?? [];
        
        // Sort appointments in memory instead of in the query
        appointments.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = (aData['date'] as Timestamp).toDate();
          final bDate = (bData['date'] as Timestamp).toDate();
          return bDate.compareTo(aDate); // Descending order
        });

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun message',
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
                    'Vos conversations avec les médecins apparaîtront ici',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index].data() as Map<String, dynamic>;
            final appointmentId = appointments[index].id;
            final appointmentDate = (appointment['date'] as Timestamp).toDate();

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .get(),
              builder: (context, messagesSnapshot) {
                final lastMessage = messagesSnapshot.data?.docs.isNotEmpty == true
                    ? messagesSnapshot.data!.docs.first.data() as Map<String, dynamic>
                    : null;
                final lastMessageTime = lastMessage?['timestamp'] as Timestamp?;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: appointment['status'] == 'annulé' 
                        ? null // Disable tap for cancelled appointments
                        : () {
                            final doctorDetails = {
                              'id': appointment['doctorId'],
                              'name': appointment['doctorName'],
                              'speciality': appointment['specialty'],
                              'photo': appointment['photo'],
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  doctor: doctorDetails,
                                  appointmentId: appointmentId,
                                ),
                              ),
                            );
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: appointment['status'] == 'annulé'
                                    ? Colors.grey[300]
                                    : const Color(0xFF0D8B8B).withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: appointment['status'] == 'annulé'
                                      ? Colors.grey
                                      : const Color(0xFF0D8B8B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment['doctorName'] ?? 'Médecin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: appointment['status'] == 'annulé'
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      appointment['specialty'] ?? 'Spécialité non spécifiée',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (lastMessageTime != null && appointment['status'] != 'annulé')
                                Text(
                                  DateFormat('HH:mm').format(lastMessageTime.toDate()),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: appointment['status'] == 'annulé'
                                      ? Colors.red.withOpacity(0.1)
                                      : const Color(0xFF0D8B8B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'RDV le ${DateFormat('dd/MM/yyyy à HH:mm').format(appointmentDate)}',
                                  style: TextStyle(
                                    color: appointment['status'] == 'annulé'
                                        ? Colors.red
                                        : const Color(0xFF0D8B8B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (appointment['status'] == 'annulé') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Annulé',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (appointment['status'] != 'annulé') ...[
                            if (lastMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                lastMessage['text'] as String? ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (messagesSnapshot.data?.docs.isEmpty ?? true) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Aucun message - Démarrer la conversation',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ] else ...[
                            const SizedBox(height: 8),
                            Text(
                              'La messagerie n\'est plus disponible pour ce rendez-vous',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}