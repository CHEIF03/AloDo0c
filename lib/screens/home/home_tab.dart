import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../InformationDoc/doctors_screen.dart';
import '../InformationDoc/doctor_details_screen.dart';

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
                    String randomImage = _profileImages[index % _profileImages.length];
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
                color: const Color(0xFF0D8B8B),
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