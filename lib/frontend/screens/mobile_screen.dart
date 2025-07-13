import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:flutter/services.dart' show rootBundle;

enum MobileClientCategory {
  apeluri,
  reveniri,
  recente,
}

class MobileClientsScreen extends StatefulWidget {
  const MobileClientsScreen({super.key});

  @override
  State<MobileClientsScreen> createState() => _MobileClientsScreenState();
}

class _MobileClientsScreenState extends State<MobileClientsScreen> {
  MobileClientCategory _currentCategory = MobileClientCategory.apeluri;
  
  // Cache pentru clienti pentru a evita rebuild-uri
  late final List<ClientModel> _allClients;

  @override
  void initState() {
    super.initState();
    _initializeClients();
  }

  void _initializeClients() {
    _allClients = [
      ClientModel(
        id: '1',
        name: 'Popescu Ion',
        phoneNumber1: '0712345678',
        status: ClientStatus.normal,
        category: ClientCategory.apeluri,
        formData: {},
      ),
      ClientModel(
        id: '2',
        name: 'Ionescu Maria',
        phoneNumber1: '0722333444',
        status: ClientStatus.normal,
        category: ClientCategory.apeluri,
        formData: {},
      ),
      ClientModel(
        id: '3',
        name: 'Vasilescu Ana',
        phoneNumber1: '0733444555',
        status: ClientStatus.normal,
        category: ClientCategory.reveniri,
        formData: {},
      ),
      ClientModel(
        id: '4',
        name: 'Georgescu Mihai',
        phoneNumber1: '0744555666',
        status: ClientStatus.normal,
        category: ClientCategory.recente,
        formData: {},
      ),
      ClientModel(
        id: '5',
        name: 'Dumitrescu Elena',
        phoneNumber1: '0755666777',
        status: ClientStatus.normal,
        category: ClientCategory.apeluri,
        formData: {},
      ),
      ClientModel(
        id: '6',
        name: 'Stoica Andrei',
        phoneNumber1: '0766777888',
        status: ClientStatus.normal,
        category: ClientCategory.reveniri,
        formData: {},
      ),
      ClientModel(
        id: '7',
        name: 'Marinescu Cristina',
        phoneNumber1: '0777888999',
        status: ClientStatus.normal,
        category: ClientCategory.recente,
        formData: {},
      ),
      ClientModel(
        id: '8',
        name: 'Nicolae Stefan',
        phoneNumber1: '0788999000',
        status: ClientStatus.normal,
        category: ClientCategory.apeluri,
        formData: {},
      ),
      ClientModel(
        id: '9',
        name: 'Popa Daniela',
        phoneNumber1: '0799000111',
        status: ClientStatus.normal,
        category: ClientCategory.reveniri,
        formData: {},
      ),
      ClientModel(
        id: '10',
        name: 'Ilie Radu',
        phoneNumber1: '0700111222',
        status: ClientStatus.normal,
        category: ClientCategory.recente,
        formData: {},
      ),
    ];
  }

  Future<void> _callClient(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Error launching phone call: $e');
    }
  }

  List<ClientModel> _getClientsForCategory() {
    switch (_currentCategory) {
      case MobileClientCategory.apeluri:
        return _allClients.where((client) => client.category == ClientCategory.apeluri).toList();
      case MobileClientCategory.reveniri:
        return _allClients.where((client) => client.category == ClientCategory.reveniri).toList();
      case MobileClientCategory.recente:
        return _allClients.where((client) => client.category == ClientCategory.recente).toList();
    }
  }

  String _getCategoryTitle() {
    switch (_currentCategory) {
      case MobileClientCategory.apeluri:
        return 'Apeluri';
      case MobileClientCategory.reveniri:
        return 'Reveniri';
      case MobileClientCategory.recente:
        return 'Recente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final clients = _getClientsForCategory();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(
          top: 32,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: AppTheme.containerColor2,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.popupBackground,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _getCategoryTitle(),
                        style: AppTheme.safeOutfit(
                          color: AppTheme.elementColor2,
                          fontSize: 19,
                          fontWeight: AppTheme.fontWeightSemiBold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista de clienti
                    Expanded(
                      child: ListView.separated(
                        itemCount: clients.length,
                        cacheExtent: 100,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          return _buildClientCard(client);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bara de navigare
            Container(
              width: 256,
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.popupBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavigationButton(
                    MobileClientCategory.apeluri,
                    'assets/callIcon.svg',
                  ),
                  _buildNavigationButton(
                    MobileClientCategory.reveniri,
                    'assets/returnIcon.svg',
                  ),
                  _buildNavigationButton(
                    MobileClientCategory.recente,
                    'assets/historyIcon.svg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.containerColor1,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: AppTheme.safeOutfit(
                    color: AppTheme.elementColor2,
                    fontSize: 17,
                    fontWeight: AppTheme.fontWeightSemiBold,
                  ),
                ),
                Text(
                  client.phoneNumber1,
                  style: AppTheme.safeOutfit(
                    color: AppTheme.elementColor1,
                    fontSize: 15,
                    fontWeight: AppTheme.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callClient(client.phoneNumber1),
            child: SizedBox(
              width: 24,
              height: 24,
              child: _buildClientIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(MobileClientCategory category, String iconPath) {
    final isActive = _currentCategory == category;
    
    return GestureDetector(
      onTap: () => setState(() => _currentCategory = category),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.containerColor2 : AppTheme.containerColor1,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: _buildIcon(iconPath, isActive),
      ),
    );
  }

  Widget _buildIcon(String iconPath, bool isActive) {
    return FutureBuilder(
      future: _loadSvgAsset(iconPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isActive ? Colors.white : AppTheme.elementColor2,
              BlendMode.srcIn,
            ),
          );
        } else {
          // Fallback la icon-uri Material
          IconData iconData;
          switch (iconPath) {
            case 'assets/callIcon.svg':
              iconData = Icons.phone;
              break;
            case 'assets/returnIcon.svg':
              iconData = Icons.replay;
              break;
            case 'assets/historyIcon.svg':
              iconData = Icons.history;
              break;
            default:
              iconData = Icons.phone;
          }
          
          return Icon(
            iconData,
            size: 24,
            color: isActive ? Colors.white : AppTheme.elementColor2,
          );
        }
      },
    );
  }

  Widget _buildClientIcon() {
    return FutureBuilder(
      future: _loadSvgAsset('assets/callIcon.svg'),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return SvgPicture.asset(
            'assets/callIcon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppTheme.elementColor2,
              BlendMode.srcIn,
            ),
          );
        } else {
          // Fallback la icon-uri Material
          return Icon(
            Icons.phone,
            size: 24,
            color: AppTheme.elementColor2,
          );
        }
      },
    );
  }

  Future<bool> _loadSvgAsset(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      debugPrint('Error loading SVG asset $assetPath: $e');
      return false;
    }
  }
} 