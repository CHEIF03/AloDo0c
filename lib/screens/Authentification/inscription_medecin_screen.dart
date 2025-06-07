import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
//TEST
class InscriptionMedecinScreen extends StatefulWidget {
  const InscriptionMedecinScreen({Key? key}) : super(key: key);

  @override
  State<InscriptionMedecinScreen> createState() => _InscriptionMedecinScreenState();
}

class _InscriptionMedecinScreenState extends State<InscriptionMedecinScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneCabinetController = TextEditingController();
  final _telephoneMobileController = TextEditingController();
  final _inpeController = TextEditingController();

  // Variables pour les  champs dropdown
  String? _titre;
  String? _ville;
  String? _specialite;

  // Variables pour les cases à cocher
  bool _accepteConditions = false;
  bool _accepteCommunications = false;

  // Variable pour le chargement
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneCabinetController.dispose();
    _telephoneMobileController.dispose();
    _inpeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D8B8B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 30),
                  // Logo
                  Center(
                    child: AloDocLogo(height: 80),
                  ),

                  const SizedBox(height: 30),

                  // Titre de la page
                  const Text(
                    'Rejoignez notre Équipe Médicale',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D8B8B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Ligne 1: Titre et Ville
                  Row(
                    children: [
                      // Titre dropdown
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _titre,
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            style: const TextStyle(color: Colors.black87),
                            onChanged: (String? newValue) {
                              setState(() {
                                _titre = newValue;
                              });
                            },
                            items: <String>['Dr.', 'Pr.']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      // Ville dropdown
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _ville,
                            decoration: const InputDecoration(
                              labelText: 'Ville',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            style: const TextStyle(color: Colors.black87),
                            onChanged: (String? newValue) {
                              setState(() {
                                _ville = newValue;
                              });
                            },
                            items: <String>['Casablanca', 'Rabat', 'Tanger', 'Agadir', 'Fes', 'Meknes', 'Sidi Kacem']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Ligne 2: Prénom et Nom
                  Row(
                    children: [
                      // Prénom
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Champ obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      // Nom
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Champ obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Ligne 3: Email et Mot de passe
                  Row(
                    children: [
                      // Email
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Adresse email',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Champ obligatoire';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Adresse email invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      // Mot de passe
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Champ obligatoire';
                              }
                              if (value.length < 8) {
                                return 'Minimum 8 caractères';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Ligne 4: Spécialité
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _specialite,
                      decoration: const InputDecoration(
                        labelText: 'Spécialité',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      style: const TextStyle(color: Colors.black87),
                      onChanged: (String? newValue) {
                        setState(() {
                          _specialite = newValue;
                        });
                      },
                      items: <String>[
                        'Médecine générale',
                        'Cardiologie',
                        'Dermatologie',
                        'Pédiatrie',
                        'Psychiatrie',
                        'Gynécologie',
                        'Neurologie',
                        'Ophtalmologie',
                        'ORL'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Ligne 5: Code INPE
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _inpeController,
                      decoration: const InputDecoration(
                        labelText: 'Code INPE',
                        hintText: 'Ex: INPE123456AB (12 caractères)',
                        helperText: 'Format: lettres majuscules et chiffres uniquement',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Code INPE obligatoire';
                        }
                        if (!RegExp(r'^[A-Z0-9]{12}$').hasMatch(value)) {
                          return 'Format invalide. Ex: INPE123456AB';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(letterSpacing: 1.5), // Pour une meilleure lisibilité
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Ligne 6: Téléphone cabinet
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _telephoneCabinetController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone du cabinet',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Champ obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Ligne 7: Téléphone mobile
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _telephoneMobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone mobile',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Champ obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ligne 8: Case à cocher Conditions d'utilisation
                  Row(
                    children: [
                      Switch(
                        value: _accepteConditions,
                        onChanged: (value) {
                          setState(() {
                            _accepteConditions = value;
                          });
                        },
                        activeColor: const Color(0xFF0D8B8B),
                      ),
                      Expanded(
                        child: Text(
                          "J'accepte les règles et conditions d'utilisation de AloDoc. En cochant cette case, je m'engage à respecter les normes",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Ligne 9: Case à cocher Communications
                  Row(
                    children: [
                      Switch(
                        value: _accepteCommunications,
                        onChanged: (value) {
                          setState(() {
                            _accepteCommunications = value;
                          });
                        },
                        activeColor: Colors.grey,
                      ),
                      Expanded(
                        child: Text(
                          "J'accepte de recevoir des communications et des informations de la part de AloDoc concernant les mises à jour",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Bouton S'inscrire
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _accepteConditions) {
                          try {
                            setState(() {
                              _isLoading = true;
                            });

                            // Créer l'utilisateur dans Firebase Auth
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );

                            // Créer le document du médecin dans Firestore
                            await FirebaseFirestore.instance.collection('doctors').doc(userCredential.user!.uid).set({
                              'titre': _titre,
                              'prenom': _prenomController.text,
                              'nom': _nomController.text,
                              'email': _emailController.text,
                              'ville': _ville,
                              'specialite': _specialite,
                              'inpe': _inpeController.text.toUpperCase(),
                              'telephoneCabinet': _telephoneCabinetController.text,
                              'telephoneMobile': _telephoneMobileController.text,
                              'accepteCommunications': _accepteCommunications,
                              'createdAt': FieldValue.serverTimestamp(),
                              'role': 'doctor',
                              'isApproved': false, // Nécessite une approbation admin
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Inscription réussie! En attente d\'approbation.'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );

                              // Attendre que le message soit affiché avant de naviguer
                              await Future.delayed(const Duration(seconds: 3));
                              
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'weak-password':
                                message = 'Le mot de passe est trop faible.';
                                break;
                              case 'email-already-in-use':
                                message = 'Un compte existe déjà avec cet email.';
                                break;
                              case 'invalid-email':
                                message = 'L\'adresse email n\'est pas valide.';
                                break;
                              default:
                                message = 'Une erreur s\'est produite: ${e.message}';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Une erreur s\'est produite: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        } else if (!_accepteConditions) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez accepter les conditions d\'utilisation'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8B8B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Lien Se connecter
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous avez déjà un compte ? ",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                              color: Color(0xFF0D8B8B),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Nouvelle implémentation du logo utilisant l'image
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
          color: Colors.grey.shade200,
          child: const Center(
            child: Text(
              'AloDoc',
              style: TextStyle(
                fontSize: 24,
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