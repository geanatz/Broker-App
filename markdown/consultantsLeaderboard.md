ConstrainedBox(
    constraints: BoxConstraints(minWidth: 520, minHeight: 432),
    child: Container(
        width: 600,
        height: 803,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
            color: const Color(0xFFD9D9D9) /* widgetBackground */,
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
                                                'Top consultanti',
                                                style: TextStyle(
                                                    color: const Color(0xFF8A8AA8) /* elementColor1 */,
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
                Expanded(
                    child: Container(
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
                                    height: 21,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
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
                                                    height: 21,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                            'Pozitie',
                                                                            style: TextStyle(
                                                                                color: const Color(0xFF666699) /* elementColor2 */,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: 21,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                            'Nume',
                                                                            style: TextStyle(
                                                                                color: const Color(0xFF666699) /* elementColor2 */,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: 21,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                            'Apeluri',
                                                                            style: TextStyle(
                                                                                color: const Color(0xFF666699) /* elementColor2 */,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: 21,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                            'Formulare',
                                                                            style: TextStyle(
                                                                                color: const Color(0xFF666699) /* elementColor2 */,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: 21,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                            'Intalniri',
                                                                            style: TextStyle(
                                                                                color: const Color(0xFF666699) /* elementColor2 */,
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
                                            ),
                                        ],
                                    ),
                                ),
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
                                            children: [
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '1',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Claudiu Vasile',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '764',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '168',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '22',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '2',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Andreea Marin',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '124',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '20',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '2',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '3',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Trif Ionut Rege',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '9,999',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '9,999',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '9,999',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '4',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Robert Valentin',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '214',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '49',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '10',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '5',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Florentin Hriscu',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '378',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '87',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '12',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '6',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Zaharia Daniel',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '126',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '31',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '7',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '7',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Kylian Mbappe',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '742',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '290',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '49',
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
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 40,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '8',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            'Lionel Messi',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '985',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '401',
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
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
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
                                                                                            '120',
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
                                                            ),
                                                        ],
                                                    ),
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
    ),
)