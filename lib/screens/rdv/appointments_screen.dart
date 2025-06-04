import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Liste des rendez-vous (données fictives)
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'doctorName': 'Dr. Karim Alami',
      'specialty': 'Cardiologue',
      'date': DateTime(2025, 4, 24, 10, 30),
      'status': 'confirmé',
      'notes': 'Consultation de routine',
      'location': 'Clinique CardioSanté, Cabinet 304',
      'address': '123 Avenue Mohammed V, Rabat',
      'phone': '+212522123456',
      'requiredDocs': [
        'Carte vitale',
        'Derniers résultats',
        'Électrocardiogramme'
      ],
      'preparation': 'Aucune préparation spécifique requise',
      'photo': 'assets/images/med1.jpg',
    },
    {
      'id': '2',
      'doctorName': 'Dr. Amina Benali',
      'specialty': 'Dermatologue',
      'date': DateTime(2025, 4, 26, 14, 0),
      'status': 'en attente',
      'notes': 'Vérification de lésion cutanée',
      'location': 'Centre médical DermaCare, 2ème étage',
      'address': '45 Rue Ibn Battouta, Casablanca',
      'phone': '+212522789012',
      'requiredDocs': ['Carte vitale', 'Photos des lésions précédentes'],
      'preparation': 'Ne pas appliquer de crème 24h avant la consultation',
      'photo': 'assets/images/doc8.jpeg',
    },
    {
      'id': '3',
      'doctorName': 'Dr. Mehdi Rami',
      'specialty': 'Ophtalmologue',
      'date': DateTime(2025, 5, 2, 9, 15),
      'status': 'confirmé',
      'notes': 'Contrôle de la vue annuel',
      'location': 'Centre Vision Plus, Cabinet 12',
      'address': '78 Boulevard Anfa, Casablanca',
      'phone': '+212522345678',
      'requiredDocs': ['Carte vitale', 'Dernière ordonnance lunettes'],
      'preparation': 'Ne pas porter de lentilles le jour du rendez-vous',
      'photo': 'assets/images/med2.png',
    },
    {
      'id': '4',
      'doctorName': 'Dr. Fatima Zahra',
      'specialty': 'Endocrinologue',
      'date': DateTime(2025, 5, 10, 11, 0),
      'status': 'confirmé',
      'notes': 'Suivi diabète',
      'location': 'Hôpital Central, Bâtiment B, 4ème étage',
      'address': '90 Avenue Hassan II, Rabat',
      'phone': '+212522901234',
      'requiredDocs': [
        'Carnet de suivi diabète',
        'Résultats analyses récentes'
      ],
      'preparation': 'Venir à jeun si possible. Apporter carnet de glycémie.',
      'photo': 'assets/images/doc6.jpeg',
    },
    {
      'id': '5',
      'doctorName': 'Dr. Hassan Ouazzani',
      'specialty': 'Dentiste',
      'date': DateTime(2025, 3, 15, 16, 30),
      'status': 'terminé',
      'notes': 'Détartrage et contrôle',
      'location': 'Cabinet Dental Care, Avenue Mohammed V',
      'address': '156 Avenue Mohammed V, Marrakech',
      'phone': '+212522567890',
      'requiredDocs': ['Carte vitale', 'Radiographies précédentes'],
      'preparation': 'Brossage des dents avant le rendez-vous',
      'photo': 'assets/images/med4.jpeg',
    },
    {
      'id': '6',
      'doctorName': 'Dr. Leila Tazi',
      'specialty': 'Pédiatre',
      'date': DateTime(2025, 3, 10, 9,
          0),
      'status': 'annulé',
      'notes': 'Visite de routine pour enfant',
      'location': 'Centre PédiaPlus, Rue Hassan II',
      'address': '34 Rue Hassan II, Tanger',
      'phone': '+212522678901',
      'requiredDocs': ['Carnet de santé', 'Carnet de vaccination'],
      'preparation': 'Aucune préparation spécifique requise',
      'photo': 'assets/images/doc5.jpeg',
    },
  ];

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

  // Filtrer les rendez-vous par statut
  List<Map<String, dynamic>> get _upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) {
      return appointment['date'].isAfter(now) &&
          (appointment['status'] == 'confirmé' ||
              appointment['status'] == 'en attente') &&
          _matchesSearch(appointment);
    })
        .toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }

  List<Map<String, dynamic>> get _pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) {
      return (appointment['date'].isBefore(now) ||
          appointment['status'] == 'terminé' ||
          appointment['status'] == 'annulé') &&
          _matchesSearch(appointment);
    })
        .toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));
  }

  bool _matchesSearch(Map<String, dynamic> appointment) {
    if (_searchQuery.isEmpty) return true;

    return appointment['doctorName'].toLowerCase().contains(_searchQuery) ||
        appointment['specialty'].toLowerCase().contains(_searchQuery) ||
        appointment['location'].toLowerCase().contains(_searchQuery);
  }

  // Obtenir les rendez-vous pour un jour spécifique
  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _appointments
        .where((appointment) {
      final appointmentDate = appointment['date'] as DateTime;
      return appointmentDate.year == day.year &&
          appointmentDate.month == day.month &&
          appointmentDate.day == day.day &&
          _matchesSearch(appointment);
    })
        .toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Action pour gérer les notifications
              _showNotificationSettings();
            },
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un rendez-vous...',
                    prefixIcon: const Icon(
                        Icons.search, color: Color(0xFF0D8B8B)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // TabBar
              TabBar(
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
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildUpcomingTab(),
          _buildPastTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorsScreen(),
            ),
          ).then((result) {
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                _appointments.add(result);
              });
            }
          });
        },
        backgroundColor: const Color(0xFF0D8B8B),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rendez-vous'),
      ),
    );
  }

  // Onglet Calendrier
  Widget _buildCalendarTab() {
    final selectedDayAppointments = _getAppointmentsForDay(_selectedDay);

    return Column(
      children: [
        // Calendrier
        Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mois',
                CalendarFormat.week: 'Semaine',
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
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
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF0D8B8B),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF0D8B8B),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF0D8B8B).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dayAppointments = _getAppointmentsForDay(date);
                  if (dayAppointments.isEmpty) return null;

                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0D8B8B),
                      ),
                      child: Text(
                        dayAppointments.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Date sélectionnée
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.event,
                color: Color(0xFF0D8B8B),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDay),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Rendez-vous pour la date sélectionnée
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
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showNewAppointmentDialog(initialDate: _selectedDay),
                  icon: const Icon(Icons.add),
                  label: const Text('Prendre un rendez-vous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8B8B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: selectedDayAppointments.length,
            itemBuilder: (context, index) {
              final appointment = selectedDayAppointments[index];
              return _buildAppointmentCard(appointment);
            },
          ),
        ),
      ],
    );
  }

  // Onglet À venir
  Widget _buildUpcomingTab() {
    return _upcomingAppointments.isEmpty
        ? _buildEmptyState(
      icon: Icons.event_busy,
      title: 'Aucun rendez-vous à venir',
      subtitle: 'Prenez rendez-vous avec un professionnel de santé',
      buttonText: 'Prendre un rendez-vous',
      onButtonPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorsScreen(),
          ),
        );
      },
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  // Onglet Historique
  Widget _buildPastTab() {
    return _pastAppointments.isEmpty
        ? _buildEmptyState(
      icon: Icons.history,
      title: 'Aucun historique de rendez-vous',
      subtitle: 'Vos rendez-vous passés apparaîtront ici',
    )
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _pastAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  // État vide générique
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorsScreen(),
                  ),
                ).then((result) {
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _appointments.add(result);
                    });
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8B8B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Carte de rendez-vous
  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor;
    IconData statusIcon;
    final status = appointment['status'];
    final appointmentDate = appointment['date'] as DateTime;

    if (status == 'confirmé') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'en attente') {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else if (status == 'terminé') {
      statusColor = Colors.blue;
      statusIcon = Icons.task_alt;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    // Déterminer si le rendez-vous est futur
    final bool isUpcoming = appointmentDate.isAfter(DateTime.now()) &&
        (status == 'confirmé' || status == 'en attente');

    // Déterminer si le rendez-vous est aujourd'hui
    final bool isToday = appointmentDate.year == DateTime
        .now()
        .year &&
        appointmentDate.month == DateTime
            .now()
            .month &&
        appointmentDate.day == DateTime
            .now()
            .day;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête avec icône si c'est aujourd'hui
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.today,
                        color: Color(0xFF0D8B8B),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Aujourd'hui",
                        style: TextStyle(
                          color: Color(0xFF0D8B8B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  // Photo du médecin
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: appointment['photo'] != null
                          ? Image.asset(
                        appointment['photo'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      )
                          : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Informations du médecin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['doctorName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment['specialty'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statut du rendez-vous
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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
                          status.substring(0, 1).toUpperCase() +
                              status.substring(1),
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

              const SizedBox(height: 16),

              // Date et heure
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
                        DateFormat('dd/MM/yyyy').format(appointmentDate),
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
                        DateFormat('HH:mm').format(appointmentDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Lieu
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

              // Notes
              if (appointment['notes']?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  appointment['notes'],
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Actions pour les rendez-vous à venir
              if (isUpcoming) ...[
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.phone,
                      label: 'Appeler',
                      onPressed: () => _callDoctor(appointment),
                    ),
                    _buildActionButton(
                      icon: Icons.map,
                      label: 'Itinéraire',
                      onPressed: () => _openMap(appointment),
                    ),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Partager',
                      onPressed: () => _shareAppointment(appointment),
                    ),
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Modifier',
                      onPressed: () => _editAppointment(appointment),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Bouton d'action pour la carte de rendez-vous
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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

  // Appeler le médecin
  void _callDoctor(Map<String, dynamic> appointment) {
    final Uri phoneUri = Uri.parse('tel:${appointment['phone']}');
    launchUrl(phoneUri);
  }

  // Ouvrir la carte pour l'itinéraire
  void _openMap(Map<String, dynamic> appointment) {
    MapsLauncher.launchQuery(appointment['address']);
  }

  // Partager le rendez-vous
  void _shareAppointment(Map<String, dynamic> appointment) {
    final appointmentDate = appointment['date'] as DateTime;
    final formattedDate = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(
        appointmentDate);

    final textToShare = '''
Rendez-vous médical:
${appointment['doctorName']} (${appointment['specialty']})
Le $formattedDate
À ${appointment['location']}
${appointment['address']}
''';

    Share.share(textToShare, subject: 'Mon rendez-vous médical');
  }

  // Modifier un rendez-vous
  void _editAppointment(Map<String, dynamic> appointment) {
    _showEditAppointmentDialog(appointment, null, null);
  }

  // Afficher les détails du rendez-vous
  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final appointmentDate = appointment['date'] as DateTime;
    final bool isUpcoming = appointmentDate.isAfter(DateTime.now()) &&
        (appointment['status'] == 'confirmé' ||
            appointment['status'] == 'en attente');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: controller,
                  children: [
                // Barre en haut
                Center(
                child: Container(
                width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ),
                const SizedBox(height: 20),
                // Titre
                const Text(
                  'Détails du rendez-vous',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),

                // Information du médecin
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: appointment['photo'] != null
                            ? Image.asset(
                          appointment['photo'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            );
                          },
                        )
                            : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['doctorName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appointment['specialty'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor(appointment['status'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  appointment['status']
                                      .substring(0, 1)
                                      .toUpperCase() +
                                      appointment['status'].substring(1),
                                  style: TextStyle(
                                    color: getStatusColor(
                                        appointment['status']),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Informations du rendez-vous - Section 1
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        Icons.event,
                        'Date',
                        DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(
                            appointmentDate),
                      ),
                      const SizedBox(height: 15),
                      _buildDetailItem(
                        Icons.access_time,
                        'Heure',
                        DateFormat('HH:mm').format(appointmentDate),
                      ),
                      const SizedBox(height: 15),
                      _buildDetailItem(
                        Icons.location_on,
                        'Lieu',
                        appointment['location'] ?? 'Non spécifié',
                      ),
                      const SizedBox(height: 15),
                      _buildDetailItem(
                        Icons.map,
                        'Adresse',
                        appointment['address'] ?? 'Non spécifiée',
                        onTap: () => _openMap(appointment),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Informations du rendez-vous - Section 2
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (appointment['notes']?.isNotEmpty ?? false) ...[
                        _buildDetailItem(
                          Icons.note,
                          'Notes',
                          appointment['notes'] ?? 'Aucune note',
                        ),
                        const SizedBox(height: 15),
                      ],
                      _buildDetailItem(
                        Icons.phone,
                        'Téléphone',
                        appointment['phone'] ?? 'Non spécifié',
                        onTap: () => _callDoctor(appointment),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Documents requis:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        appointment['requiredDocs']?.length ?? 0,
                            (index) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF0D8B8B),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    appointment['requiredDocs'][index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                      const SizedBox(height: 15),
                      if (appointment['preparation']?.isNotEmpty ?? false)
                        _buildDetailItem(
                          Icons.info_outline,
                          'Préparation',
                          appointment['preparation'],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Actions
            if (isUpcoming)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _reminderAppointment(appointment),
                        icon: const Icon(Icons.notifications),
                        label: const Text('Rappel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D8B8B),
                          side: const BorderSide(color: Color(0xFF0D8B8B)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editAppointment(appointment);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
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
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCancelConfirmation(appointment);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler le rendez-vous'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )
            else
            Row(
            children: [
            if (appointment['status'] == 'terminé')
            Expanded(
            child: ElevatedButton.icon(
            onPressed: () {
            Navigator.pop(context);
            _showDocuments(appointment);
            },
            icon: const Icon(Icons.description),
            label: const Text('Voir les documents'),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D8B8B),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            ),
            ),
            ),
            )
            else if (appointment['status'] == 'annulé')
            Expanded(
            child: ElevatedButton.icon(
            onPressed: () {
            // Logique pour reprogrammer
            Navigator.pop(context);
            _showNewAppointmentDialog(initialReason: appointment['notes']);
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reprogrammer'),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D8B8B),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            ),
            ),
            ),
            )
            else
            Expanded(
            child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D8B8B),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            ),
            ),
            child: const Text('Fermer'),
            ),
            ),
            ],
            ),
            ],
            ),
            );
          },
        );
      },
    );
  }

  // Élément de détail pour la modal
  Widget _buildDetailItem(IconData icon,
      String label,
      String value, {
        Color? valueColor,
        VoidCallback? onTap,
      }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF0D8B8B),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  // Obtenir la couleur en fonction du statut
  Color getStatusColor(String status) {
    switch (status) {
      case 'confirmé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'terminé':
        return Colors.blue;
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Confirmation d'annulation
  void _showCancelConfirmation(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler le rendez-vous'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir annuler votre rendez-vous avec ${appointment['doctorName']} le ${DateFormat(
                    'dd/MM/yyyy à HH:mm').format(appointment['date'])} ?',
              ),
              const SizedBox(height: 16),
              const Text(
                'Motif d\'annulation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Indiquez la raison de l\'annulation (facultatif)',
                    contentPadding: EdgeInsets.all(8),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Logique d'annulation
                setState(() {
                  final index = _appointments.indexWhere((a) =>
                  a['id'] == appointment['id']);
                  if (index != -1) {
                    _appointments[index]['status'] = 'annulé';
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rendez-vous annulé'),
                    backgroundColor: Color(0xFF0D8B8B),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );
  }

  // Dialogue de nouveau rendez-vous
  void _showNewAppointmentDialog({
    Map<String, dynamic>? appointmentToEdit,
    DateTime? initialDate,
    String? initialReason,
  }) {
    if (appointmentToEdit != null) {
      // If editing an existing appointment, show the edit dialog
      _showEditAppointmentDialog(appointmentToEdit, initialDate, initialReason);
    } else {
      // For new appointments, navigate to the doctors list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorsScreen(),
        ),
      ).then((result) {
        if (result != null && result is Map<String, dynamic>) {
          // Add the new appointment to the list
          setState(() {
            _appointments.add(result);
          });
        }
      });
    }
  }

  void _showEditAppointmentDialog(
    Map<String, dynamic> appointmentToEdit,
    DateTime? initialDate,
    String? initialReason,
  ) {
    final TextEditingController doctorController = TextEditingController(
      text: appointmentToEdit['doctorName'],
    );

    // Définir la liste des spécialités médicales
    final List<String> medicalSpecialties = [
      'Cardiologie',
      'Dermatologie',
      'Endocrinologie',
      'Gastro-entérologie',
      'Gynécologie',
      'Neurologie',
      'Ophtalmologie',
      'ORL',
      'Pédiatrie',
      'Pneumologie',
      'Psychiatrie',
      'Rhumatologie',
      'Urologie',
      'Médecine générale',
      'Dentiste',
    ];

    String selectedSpecialty = appointmentToEdit['specialty'];

    final TextEditingController locationController = TextEditingController(
      text: appointmentToEdit['location'],
    );
    final TextEditingController addressController = TextEditingController(
      text: appointmentToEdit['address'],
    );
    final TextEditingController phoneController = TextEditingController(
      text: appointmentToEdit['phone'],
    );
    final TextEditingController notesController = TextEditingController(
      text: appointmentToEdit['notes'],
    );

    DateTime selectedDate = appointmentToEdit['date'];
    TimeOfDay selectedTime = TimeOfDay(
      hour: appointmentToEdit['date'].hour,
      minute: appointmentToEdit['date'].minute,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre en haut
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Titre
                    const Text(
                      'Modifier le rendez-vous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Formulaire
                    TextField(
                      controller: doctorController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du médecin *',
                        prefixIcon: Icon(Icons.person, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Spécialité
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,
                      decoration: const InputDecoration(
                        labelText: 'Spécialité *',
                        prefixIcon: Icon(Icons.medical_services, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                      ),
                      items: medicalSpecialties.map((String specialty) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedSpecialty = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // Sélection de la date
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
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

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF0D8B8B)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date *',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Sélection de l'heure
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
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

                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF0D8B8B)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Heure *',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  selectedTime.format(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu *',
                        prefixIcon: Icon(Icons.location_on, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        prefixIcon: Icon(Icons.map, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Raison / Notes',
                        prefixIcon: Icon(Icons.note, color: Color(0xFF0D8B8B)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Vérifier si les champs obligatoires sont remplis
                              if (doctorController.text.isEmpty ||
                                  selectedSpecialty.isEmpty ||
                                  locationController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez remplir tous les champs obligatoires'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Mettre à jour le rendez-vous
                              final appointmentData = {
                                'id': appointmentToEdit['id'],
                                'doctorName': doctorController.text.trim(),
                                'specialty': selectedSpecialty,
                                'date': DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                ),
                                'status': appointmentToEdit['status'],
                                'notes': notesController.text.trim(),
                                'location': locationController.text.trim(),
                                'address': addressController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'photo': appointmentToEdit['photo'],
                                'requiredDocs': appointmentToEdit['requiredDocs'],
                                'preparation': appointmentToEdit['preparation'],
                              };

                              setState(() {
                                final index = _appointments.indexWhere((a) => a['id'] == appointmentToEdit['id']);
                                if (index != -1) {
                                  _appointments[index] = appointmentData;
                                }
                              });

                              // Fermer la modal et afficher une confirmation
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rendez-vous modifié avec succès'),
                                  backgroundColor: Color(0xFF0D8B8B),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D8B8B),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Modifier'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Afficher la liste des documents
  void _showDocuments(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentDocumentsScreen(appointment: appointment),
      ),
    );
  }

  // Configurer les rappels
  void _reminderAppointment(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Configurer les rappels',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options de rappel
                  ..._buildReminderOptions(context, setState, appointment),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rappels configurés avec succès'),
                            backgroundColor: Color(0xFF0D8B8B),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8B8B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Options de rappel
  List<Widget> _buildReminderOptions(BuildContext context,
      StateSetter setState,
      Map<String, dynamic> appointment) {
    bool day_before = true;
    bool hour_before = true;
    bool custom = false;

    return [
      CheckboxListTile(
        title: const Text('1 jour avant'),
        subtitle: Text(
          'Le ${DateFormat('dd/MM/yyyy à HH:mm').format(
              appointment['date'].subtract(const Duration(days: 1)))}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: day_before,
        activeColor: const Color(0xFF0D8B8B),
        onChanged: (bool? value) {
          setState(() {
            day_before = value ?? false;
          });
        },
      ),
      CheckboxListTile(
        title: const Text('1 heure avant'),
        subtitle: Text(
          'Le ${DateFormat('dd/MM/yyyy à HH:mm').format(
              appointment['date'].subtract(const Duration(hours: 1)))}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: hour_before,
        activeColor: const Color(0xFF0D8B8B),
        onChanged: (bool? value) {
          setState(() {
            hour_before = value ?? false;
          });
        },
      ),
      CheckboxListTile(
        title: const Text('Personnalisé'),
        subtitle: custom
            ? InkWell(
          onTap: () async {
            // Logique pour sélectionner une date/heure
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: appointment['date'],
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

            if (pickedDate != null) {
              // Logique pour l'heure
              showTimePicker(
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
            }
          },
          child: Text(
            'Cliquez pour définir la date/heure',
            style: TextStyle(fontSize: 12, color: const Color(0xFF0D8B8B)),
          ),
        )
            : const Text(
            'Définir un rappel personnalisé', style: TextStyle(fontSize: 12)),
        value: custom,
        activeColor: const Color(0xFF0D8B8B),
        onChanged: (bool? value) {
          setState(() {
            custom = value ?? false;
          });
        },
      ),
    ];
  }

  // Afficher les paramètres de notification
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool enableEmail = true;
            bool enableSMS = false;
            bool enablePush = true;

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Paramètres de notification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text('Notifications par email'),
                    subtitle: const Text('Recevoir les rappels par email'),
                    value: enableEmail,
                    activeColor: const Color(0xFF0D8B8B),
                    onChanged: (bool value) {
                      setState(() {
                        enableEmail = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Notifications par SMS'),
                    subtitle: const Text('Recevoir les rappels par SMS'),
                    value: enableSMS,
                    activeColor: const Color(0xFF0D8B8B),
                    onChanged: (bool value) {
                      setState(() {
                        enableSMS = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Notifications push'),
                    subtitle: const Text(
                        'Recevoir les rappels dans l\'application'),
                    value: enablePush,
                    activeColor: const Color(0xFF0D8B8B),
                    onChanged: (bool value) {
                      setState(() {
                        enablePush = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Paramètres de notification mis à jour'),
                            backgroundColor: Color(0xFF0D8B8B),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8B8B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Widget pour afficher les documents du rendez-vous
class AppointmentDocumentsScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDocumentsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste fictive de documents
    final List<Map<String, dynamic>> documents = [
      {
        'name': 'Ordonnance',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.description,
        'type': 'PDF',
        'size': '1.2 MB',
      },
      {
        'name': 'Résultats analyses',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'icon': Icons.analytics,
        'type': 'PDF',
        'size': '3.5 MB',
      },
      {
        'name': 'Scanner',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'icon': Icons.image,
        'type': 'JPG',
        'size': '5.8 MB',
      },
      {
        'name': 'Recommandations',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.article,
        'type': 'DOC',
        'size': '450 KB',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: documents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun document disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Informations du rendez-vous
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RDV: ${appointment['doctorName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy à HH:mm').format(
                            appointment['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Titre de la section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Documents disponibles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${documents.length} document${documents.length > 1
                      ? 's'
                      : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Liste des documents
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D8B8B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        document['icon'],
                        color: const Color(0xFF0D8B8B),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      document['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(document['date']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                document['type'],
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              document['size'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.visibility, color: Color(0xFF0D8B8B)),
                          onPressed: () {
                            // Logique pour visualiser le document
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Visualisation de ${document['name']}'),
                                backgroundColor: const Color(0xFF0D8B8B),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.download, color: Color(0xFF0D8B8B)),
                          onPressed: () {
                            // Logique de téléchargement
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Téléchargement de ${document['name']}'),
                                backgroundColor: const Color(0xFF0D8B8B),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Logique pour ouvrir le document
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logique pour ajouter un nouveau document
          _showAddDocumentDialog(context);
        },
        backgroundColor: const Color(0xFF0D8B8B),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
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
              // Barre en haut
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Ajouter un document',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 30),

              // Options pour ajouter un document
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Logique pour prendre une photo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture de l\'appareil photo'),
                      backgroundColor: Color(0xFF0D8B8B),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                title: const Text('Choisir depuis la galerie'),
                subtitle: const Text('Sélectionner des images existantes'),
                onTap: () {
                  Navigator.pop(context);
                  // Logique pour ouvrir la galerie
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture de la galerie'),
                      backgroundColor: Color(0xFF0D8B8B),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.file_present,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                title: const Text('Parcourir les fichiers'),
                subtitle: const Text('PDF, DOC, images, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  // Logique pour parcourir les fichiers
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture du gestionnaire de fichiers'),
                      backgroundColor: Color(0xFF0D8B8B),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.scanner,
                    color: Color(0xFF0D8B8B),
                  ),
                ),
                title: const Text('Scanner un document'),
                subtitle: const Text('Numériser un document papier'),
                onTap: () {
                  Navigator.pop(context);
                  // Logique pour scanner un document
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture du scanner'),
                      backgroundColor: Color(0xFF0D8B8B),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}