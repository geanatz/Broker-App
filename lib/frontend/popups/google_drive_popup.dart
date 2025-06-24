import 'package:flutter/material.dart';
import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/frontend/components/headers/widget_header1.dart';

import 'package:broker_app/frontend/components/fields/input_field1.dart';

/// Popup pentru gestionarea conexiunii cu Google Drive și Google Sheets
class GoogleDrivePopup extends StatefulWidget {
  const GoogleDrivePopup({super.key});

  @override
  State<GoogleDrivePopup> createState() => _GoogleDrivePopupState();
}

class _GoogleDrivePopupState extends State<GoogleDrivePopup> {
  final GoogleDriveService _driveService = GoogleDriveService();
  final TextEditingController _searchController = TextEditingController();
  
  List<DriveSheetInfo> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _selectedSheetId;
  String? _selectedSheetName;

  @override
  void initState() {
    super.initState();
    _driveService.addListener(_onDriveServiceChanged);
    _initializeService();
  }

  @override
  void dispose() {
    _driveService.removeListener(_onDriveServiceChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDriveServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    try {
      await _driveService.initialize();
    } catch (e) {
      _showError('Eroare la inițializarea serviciului: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectToGoogleDrive() async {
    setState(() => _isLoading = true);
    try {
      final success = await _driveService.connectToGoogleDrive();
      if (success) {
        _showSuccess('Conectat cu succes la Google Drive!');
        // Caută automat Google Sheets după conectare
        await _searchSheets();
      } else {
        _showError(_driveService.lastError ?? 'Conectarea a eșuat');
      }
    } catch (e) {
      _showError('Eroare la conectare: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnectFromGoogleDrive() async {
    setState(() => _isLoading = true);
    try {
      await _driveService.disconnectFromGoogleDrive();
      _searchResults = [];
      _selectedSheetId = null;
      _selectedSheetName = null;
      _showSuccess('Deconectat de la Google Drive');
    } catch (e) {
      _showError('Eroare la deconectare: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchSheets({String? query}) async {
    if (!_driveService.isAuthenticated) {
      _showError('Nu sunteți conectat la Google Drive');
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _driveService.searchGoogleSheets(query: query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      _showError('Eroare la căutarea Google Sheets: ${e.toString()}');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _setAssignedSheet() async {
    if (_selectedSheetId == null || _selectedSheetName == null) {
      _showError('Selectați un Google Sheet mai întâi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _driveService.setAssignedSheet(
        sheetId: _selectedSheetId!,
        sheetName: _selectedSheetName!,
      );
      
      if (success) {
        _showSuccess('Google Sheet-ul a fost setat cu succes!');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showError(_driveService.lastError ?? 'Eroare la setarea Google Sheet-ului');
      }
    } catch (e) {
      _showError('Eroare la setarea Google Sheet-ului: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: AppTheme.widgetDecoration,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        const WidgetHeader1(title: 'Google Drive & Sheets Integration'),
        
        const SizedBox(height: AppTheme.smallGap),
        
        // Status și conexiune
        _buildConnectionSection(),
        
        const SizedBox(height: AppTheme.smallGap),
        
        // Secțiunea de căutare (doar dacă este conectat)
        if (_driveService.isAuthenticated) ...[
          _buildSearchSection(),
          const SizedBox(height: AppTheme.smallGap),
        ],
        
        // Lista de Google Sheets
        if (_driveService.isAuthenticated && _searchResults.isNotEmpty) ...[
          _buildSheetsListSection(),
          const SizedBox(height: AppTheme.smallGap),
        ],
        
        // Butoane de acțiune
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Se încarcă serviciul Google Drive...'),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.containerColor1,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.elementColor3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            children: [
              Icon(
                _driveService.isAuthenticated ? Icons.check_circle : Icons.error,
                color: _driveService.isAuthenticated ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _driveService.isAuthenticated ? 'Conectat' : 'Neconectat',
                style: TextStyle(
                  color: _driveService.isAuthenticated ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // User info
          if (_driveService.isAuthenticated) ...[
            const SizedBox(height: 8),
            if (_driveService.userEmail != null)
              Text('Email: ${_driveService.userEmail}', style: const TextStyle(fontSize: 12)),
            if (_driveService.userName != null)
              Text('Utilizator: ${_driveService.userName}', style: const TextStyle(fontSize: 12)),
            
            // Sheet assignat
            if (_driveService.assignedSheetId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                                     color: Colors.green.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Google Sheet Assignat:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_driveService.sheetName ?? 'Necunoscut', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
          
          // Error message
          if (_driveService.lastError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                                 color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _driveService.lastError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Căutare Google Sheets:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputField1(
                title: 'Nume Google Sheet (opțional)',
                controller: _searchController,
                hintText: 'Numele Google Sheet-ului...',
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSearching ? null : () => _searchSheets(query: _searchController.text.trim()),
              child: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Caută'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSheetsListSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google Sheets găsite (${_searchResults.length}):',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
                             decoration: BoxDecoration(
                 border: Border.all(color: AppTheme.elementColor3),
                 borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
               ),
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final sheet = _searchResults[index];
                  final isSelected = _selectedSheetId == sheet.id;
                  
                  return ListTile(
                    selected: isSelected,
                                         selectedTileColor: AppTheme.elementColor2.withValues(alpha: 0.1),
                    title: Text(sheet.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sheet.modifiedTime != null)
                          Text('Modificat: ${_formatDate(sheet.modifiedTime!)}'),
                        if (sheet.owners.isNotEmpty)
                          Text('Proprietari: ${sheet.owners.join(', ')}'),
                      ],
                    ),
                                         leading: Icon(
                       Icons.table_chart,
                       color: isSelected ? AppTheme.elementColor2 : null,
                     ),
                     trailing: isSelected
                         ? Icon(Icons.check, color: AppTheme.elementColor2)
                         : null,
                    onTap: () {
                      setState(() {
                        _selectedSheetId = sheet.id;
                        _selectedSheetName = sheet.name;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.containerColor2,
              foregroundColor: AppTheme.elementColor3,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: const Text('Închide'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_driveService.isAuthenticated) {
                      if (_selectedSheetId != null) {
                        _setAssignedSheet();
                      } else {
                        _disconnectFromGoogleDrive();
                      }
                    } else {
                      _connectToGoogleDrive();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elementColor2,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Text(_driveService.isAuthenticated
                ? (_selectedSheetId != null ? 'Setează Sheet' : 'Deconectează')
                : 'Conectează'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 