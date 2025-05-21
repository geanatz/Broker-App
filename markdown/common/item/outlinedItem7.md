Container(
    width: double.infinity,
    height: 64,
    padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 4,
                color: const Color(0xFFACACD2) /* containerColor2 */,
            ),
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
                            Text(
                                'Descriere',
                                style: TextStyle(
                                    color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
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