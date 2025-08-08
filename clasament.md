ConstrainedBox(
    constraints: BoxConstraints(minWidth: 520),
    child: Container(
        width: 600,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9) /* popupBackground */,
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
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                            Text(
                                                'Clasament',
                                                style: TextStyle(
                                                    color: const Color(0xFF666699) /* elementColor2 */,
                                                    fontSize: 19,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Container(
                                width: 120,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                        Container(
                                            width: 72,
                                            height: 24,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    SizedBox(
                                                        width: 72,
                                                        child: Text(
                                                            'Luna',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                fontSize: 15,
                                                                fontFamily: 'Outfit',
                                                                fontWeight: FontWeight.w500,
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFC4C4D4) /* containerColor1 */,
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
                            Container(
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
                                    children: [
                                        Container(
                                            width: 511,
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    'Echipa Andreea',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    '1050 puncte',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Container(
                                            width: 394,
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    'Echipa Cristina',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    '750 puncte',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Container(
                                            width: 320,
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    'Echipa Scarlat',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                    Container(
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
                                                            children: [
                                                                Text(
                                                                    '580 puncte',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        ),
    ),
)