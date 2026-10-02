import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_router.dart';

/// Level Selection Screen presenting selectable arcade stages.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  void _onLevelSelected(BuildContext context, int levelNumber) {
    Navigator.of(context).pushNamed(
      AppRouter.gamePlay,
      arguments: levelNumber,
    );
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.colorSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.colorPrimary,
            size: 18,
          ),
          onPressed: () => _onBackPressed(context),
          tooltip: 'Back to Main Menu',
        ),
        title: const Text(
          'SELECT STAGE',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppConstants.colorTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CAMPAIGN MISSIONS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: AppConstants.colorSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Level Cards Grid
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 480;
                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: AppConstants.totalLevels,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 5 : 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final levelNumber = index + 1;
                            final isUnlocked = levelNumber == 1;

                            return _LevelCard(
                              levelNumber: levelNumber,
                              isUnlocked: isUnlocked,
                              onTap: isUnlocked
                                  ? () => _onLevelSelected(context, levelNumber)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Legend / Instructions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppConstants.colorSuccess,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'UNLOCKED',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 8,
                      color: AppConstants.colorTextMuted,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppConstants.colorLocked,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LOCKED',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 8,
                      color: AppConstants.colorTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card representing a level in the level selector grid.
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.levelNumber,
    required this.isUnlocked,
    this.onTap,
  });

  final int levelNumber;
  final bool isUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppConstants.colorSurfaceLight
                : AppConstants.colorSurface.withAlpha(128),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUnlocked
                  ? AppConstants.colorPrimary
                  : AppConstants.colorBorder,
              width: isUnlocked ? 2.5 : 1.5,
            ),
            boxShadow: isUnlocked
                ? const [
                    BoxShadow(
                      color: Color(0x33FFB800),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnlocked) ...[
                const Icon(
                  Icons.stars_rounded,
                  color: AppConstants.colorPrimary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'LVL $levelNumber',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorTextPrimary,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.lock_outline_rounded,
                  color: AppConstants.colorLocked,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  'LVL $levelNumber',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 9,
                    color: AppConstants.colorTextMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
