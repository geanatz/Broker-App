Container(
    width: 432,
    height: 48,
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
    ),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
            Container(
                width: 128,
                height: 32,
                decoration: ShapeDecoration(
                    color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    shadows: [
                        BoxShadow(
                            color: Color(0x14503E29),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                        )
                    ],
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
            SizedBox(
                width: 144,
                height: 32,
                child: Text(
                    '20 - 24 Decembrie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color(0xFF7C7A77) /* light-blue-text-2 */,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                    ),
                ),
            ),
            Container(
                width: 128,
                height: 32,
                decoration: ShapeDecoration(
                    color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    shadows: [
                        BoxShadow(
                            color: Color(0x14503E29),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                        )
                    ],
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