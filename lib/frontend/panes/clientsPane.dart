import 'package:flutter/material.dart';
import '../common/appTheme.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/items/darkItem7.dart';
import '../common/components/items/lightItem7.dart';

/// ClientsPane - Interfața pentru gestionarea apelurilor clienților
/// 
/// Această interfață este împărțită în 3 secțiuni:
/// 1. Apeluri - toate apelurile active
/// 2. Reveniri - apelurile care sună ocupat sau sunt amânate
/// 3. Recente - apelurile respinse sau finalizate cu succes
/// 
/// Logica de focus:
/// - LightItem7: starea normală (viewIcon)
/// - DarkItem7: starea focusată (doneIcon)
class ClientsPane extends StatelessWidget {
  const ClientsPane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Secțiunea Apeluri
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: AppTheme.widgetBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                shadows: [AppTheme.widgetShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header pentru Apeluri
                  WidgetHeader1(title: 'Apeluri'),
                  
                  SizedBox(height: AppTheme.smallGap),
                  
                  // Lista de apeluri
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Primul apel (DarkItem7 - focusat)
                          DarkItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/doneIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate apel
                            },
                          ),
                          
                          SizedBox(height: AppTheme.smallGap),
                          
                          // Al doilea apel (LightItem7 - normal)
                          LightItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/viewIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate apel
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Reveniri
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: AppTheme.widgetBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                shadows: [AppTheme.widgetShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header pentru Reveniri
                  WidgetHeader1(title: 'Reveniri'),
                  
                  SizedBox(height: AppTheme.smallGap),
                  
                  // Lista de reveniri
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prima revenire (DarkItem7 - focusat)
                          DarkItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/doneIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate revenire
                            },
                          ),
                          
                          SizedBox(height: AppTheme.smallGap),
                          
                          // A doua revenire (LightItem7 - normal)
                          LightItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/viewIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate revenire
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Recente
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: AppTheme.widgetBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                shadows: [AppTheme.widgetShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header pentru Recente
                  WidgetHeader1(title: 'Recente'),
                  
                  SizedBox(height: AppTheme.smallGap),
                  
                  // Lista de recente
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Primul recent (DarkItem7 - focusat)
                          DarkItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/doneIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate istoric
                            },
                          ),
                          
                          SizedBox(height: AppTheme.smallGap),
                          
                          // Al doilea recent (LightItem7 - normal)
                          LightItem7(
                            title: 'Nume client',
                            description: 'Numar client',
                            svgAsset: 'assets/viewIcon.svg',
                            onTap: () {
                              // TODO: Implementare funcționalitate istoric
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
