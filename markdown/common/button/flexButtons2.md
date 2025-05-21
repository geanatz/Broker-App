Container(
    width: double.infinity,
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Expanded(
                child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFC4C4D4) /* containerColor1 */,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                        ),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Text(
                                'Titlu',
                                style: TextStyle(
                                    color: const Color(0xFF666699) /* elementColor2 */,
                                    fontSize: 17,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
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
            ),
            Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                    color: const Color(0xFFC4C4D4) /* containerColor1 */,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                    ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
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