import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  // Liste des conversations (données fictives)
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'doctorName': 'Dr. Karim Alami',
      'specialty': 'Cardiologue',
      'lastMessage': 'Bonjour, j\'ai examiné vos résultats d\'analyses, tout semble normal. Nous pourrons en discuter lors de votre prochain rendez-vous.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'unread': true,
      'photo': 'assets/images/med1.jpg',
      'isUrgent': false,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'Bonjour, j\'ai examiné vos résultats d\'analyses, tout semble normal. Nous pourrons en discuter lors de votre prochain rendez-vous.',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
          'isRead': false,
        },
        {
          'sender': 'patient',
          'text': 'Merci beaucoup Docteur. Je serai présent à mon rendez-vous la semaine prochaine.',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
          'isRead': true,
        },
      ],
    },
    {
      'id': '2',
      'doctorName': 'Dr. Amina Benali',
      'specialty': 'Dermatologue',
      'lastMessage': 'Pouvez-vous m\'envoyer une photo de la zone affectée pour que je puisse évaluer si une consultation est nécessaire avant le rendez-vous prévu?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'unread': true,
      'photo': 'assets/images/doc8.jpeg',
      'isUrgent': false,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'Bonjour, avez-vous suivi le traitement comme prescrit?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'isRead': true,
        },
        {
          'sender': 'patient',
          'text': 'Oui docteur, mais j\'ai remarqué que la zone est encore rouge et légèrement irritée.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
          'isRead': true,
        },
        {
          'sender': 'doctor',
          'text': 'Pouvez-vous m\'envoyer une photo de la zone affectée pour que je puisse évaluer si une consultation est nécessaire avant le rendez-vous prévu?',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
        },
      ],
    },
    {
      'id': '3',
      'doctorName': 'Dr. Mehdi Rami',
      'specialty': 'Ophtalmologue',
      'lastMessage': 'Votre ordonnance pour vos nouvelles lunettes est prête. Vous pouvez la récupérer à l\'accueil de mon cabinet ou je peux vous l\'envoyer par email si vous préférez.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'unread': false,
      'photo': 'assets/images/med2.png',
      'isUrgent': false,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'Votre ordonnance pour vos nouvelles lunettes est prête. Vous pouvez la récupérer à l\'accueil de mon cabinet ou je peux vous l\'envoyer par email si vous préférez.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': true,
        },
      ],
    },
    {
      'id': '4',
      'doctorName': 'Centre de Prélèvement',
      'specialty': 'Laboratoire d\'Analyses',
      'lastMessage': 'Vos résultats d\'analyses sont disponibles. Vous pouvez les consulter en ligne ou les récupérer à notre centre.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'unread': false,
      'photo': 'assets/images/lab.jpg',
      'isUrgent': false,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'Vos résultats d\'analyses sont disponibles. Vous pouvez les consulter en ligne ou les récupérer à notre centre.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': true,
        },
        {
          'sender': 'patient',
          'text': 'Merci pour l\'information. Je vais les consulter en ligne.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': true,
        },
      ],
    },
    {
      'id': '5',
      'doctorName': 'Dr. Fatima Zahra',
      'specialty': 'Endocrinologue',
      'lastMessage': 'URGENT: Vos derniers résultats de glycémie montrent des valeurs préoccupantes. Veuillez me contacter dès que possible pour ajuster votre traitement.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      'unread': true,
      'photo': 'assets/images/doc6.jpeg',
      'isUrgent': true,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'URGENT: Vos derniers résultats de glycémie montrent des valeurs préoccupantes. Veuillez me contacter dès que possible pour ajuster votre traitement.',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 6)),
          'isRead': false,
        },
      ],
    },
    {
      'id': '6',
      'doctorName': 'Pharmacie Centrale',
      'specialty': 'Pharmacie',
      'lastMessage': 'Votre médicament est à nouveau disponible. Vous pouvez venir le récupérer avec votre ordonnance.',
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
      'unread': false,
      'photo': 'assets/images/pharmacy.jpg',
      'isUrgent': false,
      'messages': [
        {
          'sender': 'doctor',
          'text': 'Nous sommes désolés, le médicament que vous recherchez est actuellement en rupture de stock. Nous vous contacterons dès qu\'il sera disponible.',
          'timestamp': DateTime.now().subtract(const Duration(days: 6)),
          'isRead': true,
        },
        {
          'sender': 'patient',
          'text': 'Merci pour l\'information. Savez-vous quand il sera à nouveau disponible ?',
          'timestamp': DateTime.now().subtract(const Duration(days: 6)),
          'isRead': true,
        },
        {
          'sender': 'doctor',
          'text': 'Nous prévoyons une livraison en fin de semaine. Nous vous tiendrons informé.',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
          'isRead': true,
        },
        {
          'sender': 'doctor',
          'text': 'Votre médicament est à nouveau disponible. Vous pouvez venir le récupérer avec votre ordonnance.',
          'timestamp': DateTime.now().subtract(const Duration(days: 4)),
          'isRead': true,
        },
      ],
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

  // Filtrer les conversations
  List<Map<String, dynamic>> get _allConversations {
    return _conversations
        .where((conversation) => _matchesSearch(conversation))
        .toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  List<Map<String, dynamic>> get _unreadConversations {
    return _conversations
        .where((conversation) =>
    conversation['unread'] && _matchesSearch(conversation))
        .toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  List<Map<String, dynamic>> get _urgentConversations {
    return _conversations
        .where((conversation) =>
    conversation['isUrgent'] && _matchesSearch(conversation))
        .toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }

  bool _matchesSearch(Map<String, dynamic> conversation) {
    if (_searchQuery.isEmpty) return true;

    return conversation['doctorName'].toLowerCase().contains(_searchQuery) ||
        conversation['specialty'].toLowerCase().contains(_searchQuery) ||
        conversation['lastMessage'].toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Messages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans les messages...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D8B8B)),
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
                  Tab(text: 'Tous'),
                  Tab(text: 'Non lus'),
                  Tab(text: 'Urgents'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsList(_allConversations),
          _buildConversationsList(_unreadConversations),
          _buildConversationsList(_urgentConversations),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewMessageDialog();
        },
        backgroundColor: const Color(0xFF0D8B8B),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  // Liste des conversations
  Widget _buildConversationsList(List<Map<String, dynamic>> conversations) {
    return conversations.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationCard(conversation);
      },
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun message',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vos conversations avec les professionnels de santé apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNewMessageDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D8B8B),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Carte de conversation
  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showConversationDetails(conversation),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du médecin/établissement
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: conversation['photo'] != null
                          ? Image.asset(
                        conversation['photo'],
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
                  if (conversation['unread'])
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D8B8B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Contenu de la conversation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête avec nom et timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation['doctorName'],
                            style: TextStyle(
                              fontWeight: conversation['unread'] ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(conversation['timestamp']),
                          style: TextStyle(
                            color: conversation['unread'] ? const Color(0xFF0D8B8B) : Colors.grey,
                            fontSize: 12,
                            fontWeight: conversation['unread'] ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Spécialité
                    Text(
                      conversation['specialty'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dernier message
                    Row(
                      children: [
                        if (conversation['isUrgent'])
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation['lastMessage'],
                            style: TextStyle(
                              color: conversation['unread'] ? Colors.black : Colors.grey[600],
                              fontWeight: conversation['unread'] ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  // Formater l'horodatage
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (date == yesterday) {
      return 'Hier';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(timestamp);
    } else {
      return DateFormat('dd/MM/yy').format(timestamp);
    }
  }

  // Afficher les détails de la conversation
  void _showConversationDetails(Map<String, dynamic> conversation) {
    // Marquer la conversation comme lue
    setState(() {
      conversation['unread'] = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationDetailScreen(conversation: conversation),
      ),
    );
  }

  // Dialogue pour nouveau message
  void _showNewMessageDialog() {
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    // Liste des contacts récents (médecins, établissements)
    final List<Map<String, dynamic>> recentContacts = [
      {
        'id': '1',
        'name': 'Dr. Karim Alami',
        'specialty': 'Cardiologue',
        'photo': 'assets/images/med1.jpg',
      },
      {
        'id': '2',
        'name': 'Dr. Amina Benali',
        'specialty': 'Dermatologue',
        'photo': 'assets/images/doc8.jpeg',
      },
      {
        'id': '3',
        'name': 'Dr. Mehdi Rami',
        'specialty': 'Ophtalmologue',
        'photo': 'assets/images/med2.png',
      },
      {
        'id': '4',
        'name': 'Centre de Prélèvement',
        'specialty': 'Laboratoire d\'Analyses',
        'photo': 'assets/images/lab.jpg',
      },
      {
        'id': '5',
        'name': 'Pharmacie Centrale',
        'specialty': 'Pharmacie',
        'photo': 'assets/images/pharmacy.jpg',
      },
    ];

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
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
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
                  'Nouveau message',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),

                // Champ destinataire
                TextField(
                  controller: recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Destinataire *',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF0D8B8B)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Contacts récents
                const Text(
                  'Contacts récents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Liste horizontale des contacts récents
                Container(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentContacts.length,
                    itemBuilder: (context, index) {
                      final contact = recentContacts[index];
                      return InkWell(
                        onTap: () {
                          recipientController.text = contact['name'];
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(contact['photo']),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                contact['name'].split(' ')[0],
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                contact['name'].split(' ').length > 1 ? contact['name'].split(' ')[1] : '',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Champ message
                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      labelText: 'Message *',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0D8B8B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Options de message
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Color(0xFF0D8B8B)),
                          onPressed: () {
                            // Logique pour joindre un fichier
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo, color: Color(0xFF0D8B8B)),
                          onPressed: () {
                            // Logique pour joindre une photo
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic, color: Color(0xFF0D8B8B)),
                          onPressed: () {
                            // Logique pour enregistrer un message vocal
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Bouton message important
                        IconButton(
                          icon: const Icon(Icons.priority_high, color: Colors.red),
                          onPressed: () {
                            // Marquer comme important
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Bouton d'envoi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (recipientController.text.isEmpty || messageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez remplir tous les champs obligatoires'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Logique d'envoi du message
                      Navigator.pop(context);

                      // Afficher une confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message envoyé avec succès'),
                          backgroundColor: Color(0xFF0D8B8B),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D8B8B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Envoyer'),
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

  // Afficher les options de filtre
  void _showFilterOptions() {
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
                'Filtrer les messages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.all_inbox, color: Color(0xFF0D8B8B)),
                title: const Text('Tous les messages'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                },
              ),

              ListTile(
                leading: const Icon(Icons.mark_email_unread, color: Color(0xFF0D8B8B)),
                title: const Text('Non lus'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
              ),

              ListTile(
                leading: const Icon(Icons.priority_high, color: Colors.red),
                title: const Text('Urgents'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(2);
                },
              ),

              ListTile(
                leading: const Icon(Icons.medical_services, color: Color(0xFF0D8B8B)),
                title: const Text('Consultations médicales'),
                onTap: () {
                  Navigator.pop(context);
                  // Filtrer par type de message (consultation)
                },
              ),

              ListTile(
                leading: const Icon(Icons.receipt_long, color: Color(0xFF0D8B8B)),
                title: const Text('Ordonnances'),
                onTap: () {
                  Navigator.pop(context);
                  // Filtrer par type de message (ordonnance)
                },
              ),

              ListTile(
                leading: const Icon(Icons.date_range, color: Color(0xFF0D8B8B)),
                title: const Text('Rendez-vous'),
                onTap: () {
                  Navigator.pop(context);
                  // Filtrer par type de message (rendez-vous)
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Afficher les paramètres de notification
  void _showNotificationSettings() {
    bool enableEmail = true;
    bool enableSMS = false;
    bool enablePush = true;
    bool enableUrgentOnly = false;

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
                    'Paramètres de notification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text('Notifications par email'),
                    subtitle: const Text('Recevoir les messages par email'),
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
                    subtitle: const Text('Recevoir les messages par SMS'),
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
                    subtitle: const Text('Recevoir les notifications dans l\'application'),
                    value: enablePush,
                    activeColor: const Color(0xFF0D8B8B),
                    onChanged: (bool value) {
                      setState(() {
                        enablePush = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Messages urgents uniquement'),
                    subtitle: const Text('Ne recevoir que les messages marqués comme urgents'),
                    value: enableUrgentOnly,
                    activeColor: const Color(0xFF0D8B8B),
                    onChanged: (bool value) {
                      setState(() {
                        enableUrgentOnly = value;
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
                            content: Text('Paramètres de notification mis à jour'),
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

// Écran de détail de conversation
class ConversationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ConversationDetailScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  _ConversationDetailScreenState createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;
  bool _showAttachOptions = false;


  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation['messages']);

    // Mettre les messages à l'état de lu
    for (var message in _messages) {
      message['isRead'] = true;
    }

    // Défiler vers le bas après le rendu initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'patient',
        'text': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isRead': false,
      });
      _messageController.clear();
      _showAttachOptions = false;
    });

    // Défiler vers le bas après envoi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simuler une réponse du médecin après un délai
    if (math.Random().nextDouble() > 0.7) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'sender': 'doctor',
              'text': 'Merci pour votre message. Je vous répondrai plus en détail dès que possible.',
              'timestamp': DateTime.now(),
              'isRead': false,
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.conversation['photo']),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation['doctorName'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.conversation['specialty'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            onPressed: () {
              // Action pour appel vidéo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité d\'appel vidéo non disponible pour le moment'),
                  backgroundColor: Color(0xFF0D8B8B),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () {
              // Action pour appel téléphonique
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité d\'appel téléphonique non disponible pour le moment'),
                  backgroundColor: Color(0xFF0D8B8B),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showConversationOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec contexte médical (optionnel)
          if (widget.conversation['isUrgent'])
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cette conversation contient des informations médicales urgentes',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Liste des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isPatient = message['sender'] == 'patient';

                // Vérifier si on doit afficher la date
                bool showDate = true;
                if (index > 0) {
                  final prevMessage = _messages[index - 1];
                  final prevDate = DateTime(
                    prevMessage['timestamp'].year,
                    prevMessage['timestamp'].month,
                    prevMessage['timestamp'].day,
                  );
                  final currentDate = DateTime(
                    message['timestamp'].year,
                    message['timestamp'].month,
                    message['timestamp'].day,
                  );

                  showDate = prevDate != currentDate;
                }

                return Column(
                  children: [
                    // Afficher la date si nécessaire
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatMessageDate(message['timestamp']),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Message
                    Row(
                      mainAxisAlignment: isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo du médecin si ce n'est pas un message du patient
                        if (!isPatient)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(widget.conversation['photo']),
                          ),

                        // Contenu du message
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          margin: EdgeInsets.only(
                            left: isPatient ? 0 : 8,
                            right: isPatient ? 8 : 0,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isPatient ? const Color(0xFF0D8B8B).withOpacity(0.9) : Colors.white,
                            borderRadius: BorderRadius.circular(20).copyWith(
                              bottomLeft: isPatient ? const Radius.circular(20) : const Radius.circular(0),
                              bottomRight: isPatient ? const Radius.circular(0) : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'],
                                style: TextStyle(
                                  color: isPatient ? Colors.white : Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(message['timestamp']),
                                    style: TextStyle(
                                      color: isPatient ? Colors.white.withOpacity(0.7) : Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (isPatient) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      message['isRead'] ? Icons.done_all : Icons.done,
                                      size: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Avatar du patient (optionnel)
                        if (isPatient)
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF0D8B8B),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Options de pièces jointes
          if (_showAttachOptions)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentOption(Icons.photo, 'Photo', Colors.green),
                  _buildAttachmentOption(Icons.insert_drive_file, 'Document', Colors.blue),
                  _buildAttachmentOption(Icons.location_on, 'Localisation', Colors.orange),
                  _buildAttachmentOption(Icons.assignment, 'Ordonnance', const Color(0xFF0D8B8B)),
                ],
              ),
            ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showAttachOptions ? Icons.close : Icons.attach_file,
                    color: const Color(0xFF0D8B8B),
                  ),
                  onPressed: () {
                    setState(() {
                      _showAttachOptions = !_showAttachOptions;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF0D8B8B)),
                  onPressed: () {
                    // Action pour l'enregistrement vocal
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0D8B8B)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        // Action pour chaque type de pièce jointe
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fonctionnalité pour joindre un(e) $label non disponible pour le moment'),
            backgroundColor: const Color(0xFF0D8B8B),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Aujourd'hui";
    } else if (messageDate == yesterday) {
      return "Hier";
    } else {
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    }
  }

  void _showConversationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre en haut
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF0D8B8B)),
              title: const Text('Voir le profil'),
              onTap: () {
                Navigator.pop(context);
                // Action pour voir le profil
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF0D8B8B)),
              title: const Text('Prendre rendez-vous'),
              onTap: () {
                Navigator.pop(context);
                // Action pour prendre rendez-vous
              },
            ),

            ListTile(
              leading: const Icon(Icons.search, color: Color(0xFF0D8B8B)),
              title: const Text('Rechercher dans les messages'),
              onTap: () {
                Navigator.pop(context);
                // Action pour rechercher
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF0D8B8B)),
              title: const Text('Désactiver les notifications'),
              onTap: () {
                Navigator.pop(context);
                // Action pour désactiver les notifications
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer la conversation', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la conversation'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer l'alerte
                Navigator.pop(context); // Retourner à la liste des conversations
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation supprimée'),
                    backgroundColor: Color(0xFF0D8B8B),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}