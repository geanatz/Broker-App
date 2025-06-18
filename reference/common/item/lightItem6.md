Container(
    width: double.infinity,
    height: 64,
    padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
    decoration: ShapeDecoration(
        color: const Color(0xFFC4C4D4) /* containerColor1 */,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
        ),
    ),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
            Expanded(
                child: Container(
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                            Text(
                                'Titlu',
                                style: TextStyle(
                                    color: const Color(0xFF666699) /* elementColor2 */,
                                    fontSize: 17,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                    color: const Color(0xFFACACD2) /* containerColor2 */,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                    ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                        Container(
                            width: 24,
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Stack(),
                        ),
                    ],
                ),
            ),
        ],
    ),
)