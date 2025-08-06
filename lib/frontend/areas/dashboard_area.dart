import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/dashboard_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../components/headers/widget_header6.dart';
import '../components/chatbot_widget.dart';


/// Area pentru dashboard care afiseaza statistici si clasamente pentru consultanti.
/// Se ocupa exclusiv cu interfata si design-ul, logica fiind gestionata de DashboardService.
class DashboardArea extends StatefulWidget {
  const DashboardArea({super.key});

  @override
  State<DashboardArea> createState() => _DashboardAreaState();
}

class _DashboardAreaState extends State<DashboardArea> {
  late final DashboardService _dashboardService;
  final Map<String, bool> _expandedTeams = {}; // Track expanded state for each team

  @override
  void initState() {
    super.initState();
    _dashboardService = SplashService().dashboardService;
    // Nu mai facem _initializeDashboard() pentru ca datele sunt deja incarcate in splash
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dashboardService,
      builder: (context, _) {
        if (_dashboardService.isLoading) {
          return _buildLoadingState();
        }
        
        if (_dashboardService.errorMessage != null) {
          return _buildErrorState();
        }
        
        return _buildDashboardContent();
      },
    );
  }

  /// Construieste continutul principal al dashboard-ului
  Widget _buildDashboardContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coloana stanga - Chatbot AI - latime mai mare
        Expanded(
          flex: 1, // Latime mai mare pentru chatbot
          child: const ChatbotWidget(),
        ),
        const SizedBox(width: AppTheme.mediumGap),
        // Coloana dreapta - Statistici si clasament combinat
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Widget statistici - fill pe orizontala
              _buildCombinedMeetingsAndStatsWidget(),
              const SizedBox(height: AppTheme.mediumGap),
              // Clasament combinat - fill pe inaltime
              Expanded(child: _buildCombinedLeaderboard()),
            ],
          ),
        ),
      ],
    );
  }

  /// Clasament combinat pentru echipe si consultanti
  Widget _buildCombinedLeaderboard() {
    final teams = _dashboardService.teamsRanking;
    final consultants = _dashboardService.consultantsRanking;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: AppTheme.widgetDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cu navigare luni pentru clasament combinat
            WidgetHeader6(
              title: 'Top echipe si consultanti',
              dateText: DateFormat('MMM yyyy', 'ro').format(_dashboardService.selectedMonth),
              onPrevDateTap: _dashboardService.goToPreviousMonth,
              onNextDateTap: _dashboardService.goToNextMonth,
              onDateTextTap: _dashboardService.goToCurrentMonth,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: AppTheme.containerColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableHeader(['Pozitie', 'Nume', 'Membri', 'Formulare', 'Intalniri'], [1, 3, 2, 2, 2]),
                    const SizedBox(height: 8),
                    Expanded(
                      child: teams.isEmpty
                          ? _buildEmptyState('Nu exista echipe in clasament')
                          : _buildCombinedTable(teams, consultants),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tabel combinat pentru echipe si consultanti
  Widget _buildCombinedTable(List<TeamRanking> teams, List<ConsultantRanking> consultants) {
    final List<Widget> tableItems = [];
    
    for (int i = 0; i < teams.length; i++) {
      final team = teams[i];
      final isExpanded = _expandedTeams[team.id] ?? false;
      
      // Adauga randul pentru echipa
      tableItems.add(_buildTeamRow(team, i + 1, isExpanded));
      
      // Daca echipa este expandata, adauga consultanti
      if (isExpanded) {
        final teamConsultants = _getConsultantsForTeam(team.teamName, consultants);
        for (int j = 0; j < teamConsultants.length; j++) {
          final consultant = teamConsultants[j];
          tableItems.add(_buildConsultantRow(consultant, j + 1, true)); // true = isSubItem
        }
      }
    }
    
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: tableItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => tableItems[index],
    );
  }

  /// Construieste randul pentru o echipa
  Widget _buildTeamRow(TeamRanking team, int position, bool isExpanded) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _buildTableCell('$position', isFirstColumn: true),
          _buildTableCell(team.teamName, flex: 3, isName: true),
          _buildTableCell(team.memberCount.toString(), flex: 2),
          _buildTableCell(team.formsCompleted.toString(), flex: 2),
          _buildTableCell(team.meetingsHeld.toString(), flex: 2),
          // Toggle button pentru expandare
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedTeams[team.id] = !isExpanded;
              });
            },
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: AppTheme.elementColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste randul pentru un consultant (sub echipa)
  Widget _buildConsultantRow(ConsultantRanking consultant, int position, bool isSubItem) {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(left: 32), // Indentare pentru consultanti
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _buildTableCell('$position', isFirstColumn: true, isSubItem: true),
          _buildTableCell(consultant.name, flex: 3, isName: true, isSubItem: true),
          _buildTableCell('-', flex: 2, isSubItem: true), // Membri nu se aplica la consultant
          _buildTableCell(consultant.formsCompleted.toString(), flex: 2, isSubItem: true),
          _buildTableCell(consultant.meetingsScheduled.toString(), flex: 2, isSubItem: true),
          // Spatiu gol pentru aliniere
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  /// Obtine consultanti pentru o echipa specifica
  List<ConsultantRanking> _getConsultantsForTeam(String teamName, List<ConsultantRanking> allConsultants) {
    // Debug: afiseaza toti consultantii pentru debugging
    debugPrint('🔍 DASHBOARD: Caut consultanti pentru echipa: $teamName');
    debugPrint('🔍 DASHBOARD: Total consultanti disponibili: ${allConsultants.length}');
    
    // Acum folosim campul team din ConsultantRanking
    final teamConsultants = allConsultants.where((consultant) => 
      consultant.team.toLowerCase() == teamName.toLowerCase()
    ).toList();
    
    debugPrint('🔍 DASHBOARD: Gasiti ${teamConsultants.length} consultanti pentru echipa $teamName');
    for (var consultant in teamConsultants) {
      debugPrint('🔍 DASHBOARD: - ${consultant.name} (echipa: ${consultant.team})');
    }
    
    return teamConsultants;
  }

  /// Widget combinat pentru intalniri si statistici (design din widgetStatistics.md)
  Widget _buildCombinedMeetingsAndStatsWidget() {
    final stats = _dashboardService.consultantStats;
    
    return Container(
      width: double.infinity, // Fill pe orizontala
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Astazi',
                          style: AppTheme.safeOutfit(
                            color: AppTheme.elementColor1,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Statistics cards row - 3 coloane
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Forms card
                _buildStatCard('assets/formIcon.svg', '${stats?.formsCompletedThisMonth ?? 0} formulare'),
                const SizedBox(width: 10),
                // Meetings card
                _buildStatCard('assets/meetingIcon.svg', '${stats?.totalMeetingsScheduled ?? 0} intalniri'),
                const SizedBox(width: 10),
                // Duty agent card
                if (_dashboardService.dutyAgent != null)
                  _buildStatCard('assets/coffeeIcon.svg', _dashboardService.dutyAgent ?? 'Nimeni'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste un card de statistica reutilizabil
  Widget _buildStatCard(String svgAsset, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: AppTheme.containerColor1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                svgAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppTheme.elementColor2,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor2,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construieste header-ul pentru tabele
  Widget _buildTableHeader(List<String> headers, List<int> flexValues) {
    assert(headers.length == flexValues.length, 'Headers and flexValues must have the same length');
    return Container(
      width: double.infinity,
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Prima coloana cu latime fixa de 80px
          Container(
            width: 80,
            height: 21,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              headers[0],
              style: AppTheme.safeOutfit(
                color: AppTheme.elementColor2,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Restul coloanelor cu Expanded
          ...List.generate(headers.length - 1, (index) => Expanded(
            flex: flexValues[index + 1],
            child: Container(
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                headers[index + 1],
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Construieste o celula de tabel
  Widget _buildTableCell(String text, {int flex = 1, bool isName = false, bool isFirstColumn = false, bool isSubItem = false}) {
    if (isFirstColumn) {
      // Prima coloana cu latime fixa de 80px
      return Container(
        width: 80,
        height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.safeOutfit(
            color: isSubItem ? AppTheme.elementColor3 : (isName ? AppTheme.elementColor2 : AppTheme.elementColor3),
            fontSize: isSubItem ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return Expanded(
      flex: flex,
      child: Container(
        height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.safeOutfit(
            color: isSubItem ? AppTheme.elementColor3 : (isName ? AppTheme.elementColor2 : AppTheme.elementColor3),
            fontSize: isSubItem ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Starea de loading
  Widget _buildLoadingState() {
    return Container(
      decoration: AppTheme.widgetDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor3),
            ),
            const SizedBox(height: 16),
            Text(
              'Se incarca dashboard-ul...',
              style: AppTheme.safeOutfit(
                fontSize: 16,
                color: AppTheme.elementColor2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Starea de eroare
  Widget _buildErrorState() {
    return Container(
      decoration: AppTheme.widgetDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.elementColor1,
            ),
            const SizedBox(height: 16),
            Text(
              'Eroare la incarcarea datelor',
              style: AppTheme.safeOutfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _dashboardService.errorMessage ?? 'Eroare necunoscuta',
              style: AppTheme.safeOutfit(
                fontSize: 14,
                color: AppTheme.elementColor1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _dashboardService.refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reincearca'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.elementColor3,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Starea goala
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: AppTheme.elementColor1,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTheme.safeOutfit(
              fontSize: 14,
              color: AppTheme.elementColor1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
