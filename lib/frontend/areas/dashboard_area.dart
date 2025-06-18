import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/dashboard_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../components/headers/widget_header6.dart';


/// Area pentru dashboard care afiseaza statistici si clasamente pentru consultanti.
/// Se ocupa exclusiv cu interfata si design-ul, logica fiind gestionata de DashboardService.
class DashboardArea extends StatefulWidget {
  const DashboardArea({super.key});

  @override
  State<DashboardArea> createState() => _DashboardAreaState();
}

class _DashboardAreaState extends State<DashboardArea> {
  late final DashboardService _dashboardService;

  @override
  void initState() {
    super.initState();
    _dashboardService = SplashService().dashboardService;
    // Nu mai facem _initializeDashboard() pentru că datele sunt deja încărcate în splash
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
        // Coloana stanga - Clasamente
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(child: _buildConsultantsLeaderboard()),
              const SizedBox(height: AppTheme.smallGap),
              Expanded(child: _buildTeamsLeaderboard()),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.smallGap),
        // Coloana dreapta - Widget-uri informative
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildCombinedMeetingsAndStatsWidget(),
            ],
          ),
        ),
      ],
    );
  }

  /// Clasamentul consultantilor (design Figma cu widgetHeader6)
  Widget _buildConsultantsLeaderboard() {
    final consultants = _dashboardService.consultantsRanking;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 520, minHeight: 432),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: AppTheme.widgetDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cu navigare luni
            WidgetHeader6(
              title: 'Top consultanti',
              dateText: DateFormat('MMMM yyyy', 'ro').format(_dashboardService.selectedMonth),
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
                    _buildTableHeader(['Pozitie', 'Nume', 'Formulare', 'Intalniri']),
                    const SizedBox(height: 8),
                    Expanded(
                      child: consultants.isEmpty
                          ? _buildEmptyState('Nu exista consultanti in clasament')
                          : _buildConsultantsTable(consultants),
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

  /// Clasamentul echipelor (design Figma cu widgetHeader6)
  Widget _buildTeamsLeaderboard() {
    final teams = _dashboardService.teamsRanking;
    
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
            // Header cu navigare luni
            WidgetHeader6(
              title: 'Top echipe',
              dateText: DateFormat('MMMM yyyy', 'ro').format(_dashboardService.selectedMonth),
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
                    _buildTableHeader(['Pozitie', 'Nume', 'Membri', 'Formulare', 'Intalniri']),
                    const SizedBox(height: 8),
                    Expanded(
                      child: teams.isEmpty
                          ? _buildEmptyState('Nu exista echipe in clasament')
                          : _buildTeamsTable(teams),
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

  /// Widget combinat pentru intalniri si statistici (design din widgetStatistics.md)
  Widget _buildCombinedMeetingsAndStatsWidget() {
    final meetings = _dashboardService.upcomingMeetings.take(5).toList(); // Maximum 5 meetings
    final stats = _dashboardService.consultantStats;
    
    return Expanded(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: AppTheme.widgetBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
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
                            'Statistici',
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
            
            // Meetings list (daca exista)
            if (meetings.isNotEmpty) ...[
              ...meetings.map((meeting) => Container(
                width: double.infinity,
                height: 52,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: AppTheme.containerColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        meeting.clientName,
                        style: AppTheme.safeOutfit(
                          color: AppTheme.elementColor2,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 104,
                      child: Text(
                        _extractPhoneFromMeeting(meeting),
                        textAlign: TextAlign.right,
                        style: AppTheme.safeOutfit(
                          color: AppTheme.elementColor1,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
            
            // Statistics cards row
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
                ],
              ),
            ),
            
            // Duty agent section
            if (_dashboardService.dutyAgent != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: AppTheme.containerColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Agent curatenie',
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor2,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _dashboardService.dutyAgent ?? 'N/A',
                      textAlign: TextAlign.right,
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor1,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
            borderRadius: BorderRadius.circular(24),
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
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extrage numarul de telefon din meeting
  String _extractPhoneFromMeeting(UpcomingMeeting meeting) {
    // Incearca sa extraga numarul de telefon din location sau alte surse
    if (meeting.location.contains('Telefon:')) {
      return meeting.location.replaceAll('Telefon: ', '');
    }
    // Pentru moment returneaza un placeholder
    return meeting.id.length > 10 ? meeting.id.substring(0, 10) : meeting.id;
  }

  /// Construieste header-ul pentru tabele
  Widget _buildTableHeader(List<String> headers) {
    return Container(
      width: double.infinity,
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: headers.map((header) => Expanded(
          child: Container(
            height: 21,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              header,
              style: AppTheme.safeOutfit(
                color: AppTheme.elementColor2,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// Tabelul consultantilor
  Widget _buildConsultantsTable(List<ConsultantRanking> consultants) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: consultants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final consultant = consultants[index];
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildTableCell('${index + 1}'),
              ),
              Expanded(
                child: _buildTableCell(consultant.name),
              ),
              Expanded(
                child: _buildTableCell('${consultant.formsCompleted}'),
              ),
              Expanded(
                child: _buildTableCell('${consultant.meetingsScheduled}'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construieste tabelul pentru echipe
  Widget _buildTeamsTable(List<TeamRanking> teams) {
    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Container(
          width: double.infinity,
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: AppTheme.containerColor2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            children: [
              _buildTableCell((index + 1).toString(), flex: 1),
              _buildTableCell(team.teamName, flex: 3, isName: true),
              _buildTableCell(team.memberCount.toString(), flex: 2),
              _buildTableCell(team.formsCompleted.toString(), flex: 2),
              _buildTableCell(team.meetingsHeld.toString(), flex: 2),
            ],
          ),
        );
      },
    );
  }

  /// Construieste o celula de tabel
  Widget _buildTableCell(String text, {int flex = 1, bool isName = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.safeOutfit(
            color: isName ? AppTheme.elementColor2 : AppTheme.elementColor3,
            fontSize: 15,
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
