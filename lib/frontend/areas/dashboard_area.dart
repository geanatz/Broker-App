import 'package:mat_finance/app_theme.dart';
import 'package:mat_finance/backend/services/dashboard_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/chatbot_widget.dart';
import '../components/headers/widget_header1.dart';
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
        // Coloana stanga - Statistici si clasament combinat
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Widget statistici - fill pe orizontala
              _buildCombinedMeetingsAndStatsWidget(),
              const SizedBox(height: AppTheme.smallGap),
              // Clasament combinat - fill pe inaltime
              Expanded(child: _buildCombinedLeaderboard()),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.smallGap),
        // Coloana dreapta - Chatbot AI
        Expanded(
          flex: 1,
          child: const ChatbotWidget(),
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
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
    
    return WidgetHeader6(
      title: title,
      dateText: _formatMonthYear(_dashboardService.selectedMonth),
      prevDateIcon: Icons.chevron_left,
      nextDateIcon: Icons.chevron_right,
      onPrevDateTap: _dashboardService.goToPreviousMonth,
      onNextDateTap: _dashboardService.goToNextMonth,
      onDateTextTap: _dashboardService.goToCurrentMonth,
      titleColor: AppTheme.elementColor1,
      dateTextColor: _isCurrentMonth() 
          ? AppTheme.elementColor1 
          : AppTheme.elementColor2,
      dateNavIconColor: AppTheme.elementColor1,
      // Custom title widget pentru a include sageata
      titleWidget: _selectedTeamId != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTeamId = null),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        'assets/leftIcon.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          AppTheme.elementColor1,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Gap de 8px
                Text(
                  title,
                  style: AppTheme.safeOutfit(
                    color: AppTheme.elementColor1,
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : null,
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
        color: AppTheme.backgroundColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
          color: AppTheme.backgroundColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
        color: AppTheme.backgroundColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
                color: AppTheme.backgroundColor3,
                borderRadius: BorderRadius.circular(20),
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
          color: AppTheme.backgroundColor3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
          WidgetHeader1(
            title: 'Astazi',
            titleColor: AppTheme.elementColor1,
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
                // Forms card (today)
                _buildStatCard('assets/formIcon.svg', '${stats?.formsCompletedToday ?? 0} formulare'),
                const SizedBox(width: 10),
                // Meetings card (today)
                _buildStatCard('assets/calendarIcon.svg', '${stats?.meetingsScheduledToday ?? 0} intalniri'),
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
          color: AppTheme.backgroundColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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

