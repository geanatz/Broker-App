import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/dashboard_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/role_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String? _selectedTeamId; // Track selected team for consultant view

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

  /// Clasament nou cu design bazat pe clasament.md
  Widget _buildCombinedLeaderboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _buildLeaderboardHeader(),
          Expanded(child: _buildLeaderboardContent()),
        ],
      ),
    );
  }

  /// Header pentru clasament cu titlu si navigare luna
  Widget _buildLeaderboardHeader() {
    final title = _selectedTeamId == null 
        ? 'Clasament' 
        : _getTeamName(_selectedTeamId!);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Titlu + back button daca e in modul consultanti
          Expanded(
            child: Container(
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  if (_selectedTeamId != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTeamId = null),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 19,
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: AppTheme.safeOutfit(
                      color: AppTheme.elementColor1,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Indicator pentru supervisor
                  if (RoleService().isSupervisor)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.elementColor3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SUPERVISOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Navigare luna
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Săgeată stânga
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: _dashboardService.goToPreviousMonth,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.chevron_left,
                        color: AppTheme.elementColor1,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              // Text data
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: _dashboardService.goToCurrentMonth,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Container(
                    width: 80,
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      _formatMonthYear(_dashboardService.selectedMonth),
                      textAlign: TextAlign.center,
                      style: AppTheme.safeOutfit(
                        color: _isCurrentMonth() 
                            ? AppTheme.elementColor1 
                            : AppTheme.elementColor2,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Săgeată dreapta
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: _dashboardService.goToNextMonth,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.chevron_right,
                        color: AppTheme.elementColor1,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Continut clasament - echipe sau consultanti
  Widget _buildLeaderboardContent() {
    if (_selectedTeamId == null) {
      return _buildTeamsRanking();
    } else {
      return _buildTeamConsultantsRanking(_selectedTeamId!);
    }
  }

  /// Clasamentul echipelor cu design nou pe coloane
  Widget _buildTeamsRanking() {
    final teams = _dashboardService.teamsRanking;
    
    if (teams.isEmpty) {
      return _buildEmptyState('Nu exista echipe in clasament');
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Spatiul disponibil pentru inaltimea barelor (rezervam spatiu pentru numele echipei)
          final double availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight - 72 // spatiu pentru nume + padding
              : 300; // fallback in caz de constrangeri nefinite

          // Garantam limite rezonabile pentru afisare
          final double minBarHeight = 80.0; // minim vizibil pentru text si punctaj
          final double maxBarHeight = availableHeight > minBarHeight
              ? availableHeight
              : minBarHeight;

          final children = <Widget>[];
          for (int i = 0; i < teams.length; i++) {
            children.add(
              Expanded(
                child: _buildTeamBar(teams[i], maxBarHeight, minBarHeight),
              ),
            );
            // Adauga gap intre bare, dar nu dupa ultima bara
            if (i < teams.length - 1) {
              children.add(const SizedBox(width: 56));
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          );
        },
      ),
    );
  }

  /// Clasamentul consultantilor dintr-o echipa
  Widget _buildTeamConsultantsRanking(String teamId) {
    final allConsultants = _dashboardService.consultantsRanking;
    final teamConsultants = _getConsultantsForTeam(teamId, allConsultants);
    
    if (teamConsultants.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: AppTheme.containerColor1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: SvgPicture.asset(
                  'assets/userIcon.svg',
                  colorFilter: ColorFilter.mode(
                    AppTheme.elementColor1,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nu exista consultanti in aceasta echipa',
                style: AppTheme.safeOutfit(
                  fontSize: 16,
                  color: AppTheme.elementColor1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
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
        spacing: 8,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: teamConsultants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final consultant = entry.value;
                  return _buildConsultantRankingRow(consultant, index + 1);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bara pentru o echipa in clasament (coloana crescanda de jos in sus)
  Widget _buildTeamBar(TeamRanking team, double maxBarHeight, double minBarHeight) {
    // Echipa cu scor maxim trebuie sa umple inaltimea disponibila
    final int maxScore = _dashboardService.teamsRanking.isNotEmpty
        ? _dashboardService.teamsRanking.first.score
        : team.score;

    final double ratio = maxScore > 0 ? (team.score / maxScore) : 0.0;

    // Interpolare liniara intre minimul vizibil si maximul disponibil
    final double barHeight = minBarHeight + (maxBarHeight - minBarHeight) * ratio;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTeamId = team.id),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
                    children: [
              // Bara cu punctajul in interior
              Container(
                width: double.infinity,
                height: barHeight,
              decoration: BoxDecoration(
                color: AppTheme.containerColor2,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
                              child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${team.score} puncte',
                      textAlign: TextAlign.center,
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor3,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Numele echipei sub bara
              Container(
                width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
                child: Text(
                  team.teamName,
                  textAlign: TextAlign.center,
                  style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor2,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
        ),
      ),
    );
  }

  /// Randul pentru un consultant in clasament echipei cu width flexibil bazat pe punctaj
  Widget _buildConsultantRankingRow(ConsultantRanking consultant, int position) {
    final teamConsultants = _getConsultantsForTeam(_selectedTeamId!, _dashboardService.consultantsRanking);
    final int maxScore = teamConsultants.isNotEmpty ? teamConsultants.first.score : 0;
    final double ratio = maxScore > 0 ? (consultant.score / maxScore) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Latimea maxima disponibila pentru bara
        final double maxWidth = constraints.maxWidth;
        final double minWidth = 220.0; // minim pentru text lizibil

        final double finalWidth = minWidth + (maxWidth - minWidth) * ratio;

            return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 64,
        width: finalWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: AppTheme.containerColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      consultant.name,
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor3,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    '${consultant.score} puncte',
                    style: AppTheme.safeOutfit(
                      color: AppTheme.elementColor3,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  /// Obtine numele echipei dupa ID
  String _getTeamName(String teamId) {
    final team = _dashboardService.teamsRanking.firstWhere(
      (t) => t.id == teamId,
      orElse: () => TeamRanking(
        id: teamId,
        teamName: 'Echipa necunoscuta',
        memberCount: 0,
        formsCompleted: 0,
        meetingsHeld: 0,
        score: 0,
      ),
    );
    return team.teamName;
  }

  /// Obtine consultanti pentru o echipa specifica
  List<ConsultantRanking> _getConsultantsForTeam(String teamId, List<ConsultantRanking> allConsultants) {
    // Gaseste numele echipei dupa ID
    final teamName = _getTeamName(teamId);
    
    // Acum folosim campul team din ConsultantRanking
    final teamConsultants = allConsultants.where((consultant) => 
      consultant.team.toLowerCase() == teamName.toLowerCase()
    ).toList();
    
    // Sorteaza consultantii dupa punctaj
    teamConsultants.sort((a, b) => b.score.compareTo(a.score));
    
    return teamConsultants;
  }

  /// Formateaza luna si anul in formatul dorit: "iul. 25", "aug. 25", etc.
  String _formatMonthYear(DateTime date) {
    final monthNames = {
      1: 'ian',
      2: 'feb', 
      3: 'mar',
      4: 'apr',
      5: 'mai',
      6: 'iun',
      7: 'iul',
      8: 'aug',
      9: 'sep',
      10: 'oct',
      11: 'noi',
      12: 'dec',
    };
    
    final month = monthNames[date.month] ?? 'ian';
    final year = date.year.toString().substring(2); // Ultimele 2 cifre ale anului
    
    return '$month. $year';
  }

  /// Verifica daca luna selectata este luna curenta
  bool _isCurrentMonth() {
    final now = DateTime.now();
    final selected = _dashboardService.selectedMonth;
    return now.year == selected.year && now.month == selected.month;
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
        padding: const EdgeInsets.symmetric(vertical: 24),
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
