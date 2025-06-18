Container(
    width: double.infinity,
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
                                            'Titlu',
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
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
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
                                ),
                                Container(
                                    width: 128,
                                    height: 24,
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            SizedBox(
                                                width: 128,
                                                child: Text(
                                                    'Date',
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
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
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
                                ),
                            ],
                        ),
                    ],
                ),
            ),
            Container(
                width: double.infinity,
                height: 984,
                padding: const EdgeInsets.all(16),
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
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
                                children: [
                                    Container(width: 40, height: double.infinity),
                                    Expanded(
                                        child: Container(
                                            height: 21,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                    'Luni 12',
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
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                    'Marti 13',
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
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                    'Miercuri 14',
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
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                    'Joi 15',
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
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                                    'Vineri 16',
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
                        Container(
                            width: double.infinity,
                            height: 923,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '9:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '10:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '10:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '11:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '11:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '12:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '12:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '13:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '13:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '14:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '14:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '15:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '15:30',
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
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                                Container(
                                                    width: 40,
                                                    height: double.infinity,
                                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                            '16:00',
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
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
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
                                                    ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                        height: 64,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: ShapeDecoration(
                                                            color: const Color(0xFFACACD2) /* containerColor2 */,
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
                                                                                        color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                                Text(
                                                                                    'Descriere',
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
                    ],
                ),
            ),
        ],
    ),
)