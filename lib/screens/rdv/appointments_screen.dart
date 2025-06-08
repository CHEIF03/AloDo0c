import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../InformationDoc/doctors_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Stream<QuerySnapshot> _getAppointmentsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: User is null');
      return const Stream.empty();
    }

    print('\nDEBUG: Current Auth State:');
    print('  User ID: ${user.uid}');
    print('  Email: ${user.email}');
    print('  Expected patientId in DB: Jx6UPGIlexeZx9z1cIuXvE6kSo43');

    return _firestore
        .collection('appointments')
        // Query without any filters first to see all appointments
        .snapshots()
        .map((snapshot) {
          print('\nDEBUG: All Appointments:');
          print('Total appointments: ${snapshot.docs.length}');
          
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('\nAppointment {');
            print('  id: ${doc.id}');
            print('  patientId: ${data['patientId']}');
            print('  patientEmail: ${data['patientEmail']}');
            print('  status: ${data['status']}');
            print('  doctorName: ${data['doctorName']}');
            print('  date: ${(data['date'] as Timestamp).toDate()}');
            print('}');
          }
          return snapshot;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Stream error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Erreur: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D8B8B),
              ),
            ),
          );
        }

        final appointments = snapshot.data?.docs ?? [];
        print('Total appointments received: ${appointments.length}');

        // Debug print all appointments
        for (var doc in appointments) {
          final data = doc.data() as Map<String, dynamic>;
          print('Appointment: {');
          print('  id: ${doc.id}');
          print('  patientId: ${data['patientId']}');
          print('  doctorName: ${data['doctorName']}');
          print('  date: ${(data['date'] as Timestamp).toDate()}');
          print('  status: ${data['status']}');
          print('}');
        }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Rendez-vous',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
            bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF0D8B8B),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0D8B8B),
                tabs: const [
                  Tab(text: 'Calendrier'),
                  Tab(text: 'À venir'),
                  Tab(text: 'Historique'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
              _buildCalendarTab(appointments),
              _buildUpcomingTab(appointments),
              _buildPastTab(appointments),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorsScreen(),
            ),
              );
        },
        backgroundColor: const Color(0xFF0D8B8B),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rendez-vous'),
      ),
        );
      },
    );
  }

  Widget _buildCalendarTab(List<QueryDocumentSnapshot> appointments) {
    final selectedDayAppointments = appointments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final appointmentDate = (data['date'] as Timestamp).toDate();
      return appointmentDate.year == _selectedDay.year &&
          appointmentDate.month == _selectedDay.month &&
          appointmentDate.day == _selectedDay.day;
    }).toList();

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
            child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            eventLoader: (day) {
              return appointments.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final appointmentDate = (data['date'] as Timestamp).toDate();
                return isSameDay(appointmentDate, day);
              }).toList();
            },
          ),
        ),
        Expanded(
          child: selectedDayAppointments.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun rendez-vous ce jour',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: selectedDayAppointments.length,
            itemBuilder: (context, index) {
                    final appointmentData = selectedDayAppointments[index].data() as Map<String, dynamic>;
                    return _buildAppointmentCard(appointmentData);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTab(List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    print('\nDEBUG: Processing appointments for Upcoming tab');
    print('Total appointments before filtering: ${appointments.length}');
    
    final upcomingAppointments = appointments
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        })
        .where((appointment) {
          final appointmentDate = (appointment['date'] as Timestamp).toDate();
          final patientId = appointment['patientId'];
          
          print('\nDEBUG: Checking appointment:');
          print('  Date: $appointmentDate');
          print('  PatientId: $patientId');
          print('  Current user: ${_auth.currentUser?.uid}');
          
          return appointmentDate.isAfter(now) && 
                 patientId == _auth.currentUser?.uid;
        })
        .toList();

    print('\nFinal upcoming appointments count: ${upcomingAppointments.length}');
    if (upcomingAppointments.isNotEmpty) {
      print('Upcoming appointments:');
      for (var appointment in upcomingAppointments) {
        print('- ${appointment['doctorName']} on ${(appointment['date'] as Timestamp).toDate()} (${appointment['status']})');
      }
    }

    // Sort appointments by date
    upcomingAppointments.sort((a, b) {
      final aDate = (a['date'] as Timestamp).toDate();
      final bDate = (b['date'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    return upcomingAppointments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun rendez-vous à venir',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
            itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
              return _buildAppointmentCard(upcomingAppointments[index]);
      },
    );
  }

  Widget _buildPastTab(List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    final pastAppointments = appointments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final appointmentDate = (data['date'] as Timestamp).toDate();
      return appointmentDate.isBefore(now);
    }).toList();

    return pastAppointments.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                  Icons.history,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
                const Text(
                  'Aucun rendez-vous passé',
                  style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pastAppointments.length,
            itemBuilder: (context, index) {
              final appointmentData = pastAppointments[index].data() as Map<String, dynamic>;
              return _buildAppointmentCard(appointmentData);
            },
          );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = (appointment['date'] as Timestamp).toDate();
    final status = appointment['status'] as String;
    final isUpcoming = appointmentDate.isAfter(DateTime.now()) &&
        (status == 'confirmé' || status == 'en attente');

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'confirmé':
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
        break;
      case 'en attente':
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
        break;
      case 'terminé':
      statusColor = Colors.blue;
      statusIcon = Icons.task_alt;
        break;
      default:
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                        status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        color: Color(0xFF0D8B8B),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(appointmentDate),
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
                        DateFormat('HH:mm').format(appointmentDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
            if (appointment['location'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF0D8B8B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment['location'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
              if (isUpcoming) ...[
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Modifier',
                    onPressed: () {
                      // Add edit logic
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.cancel,
                    label: 'Annuler',
                    onPressed: () async {
                      // Add cancel logic
                      await _firestore
                          .collection('appointments')
                          .doc(appointment['id'])
                          .update({'status': 'annulé'});
                    },
                    ),
                  ],
                ),
              ],
            ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF0D8B8B),
              size: 20,
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
      ),
    );
  }
}