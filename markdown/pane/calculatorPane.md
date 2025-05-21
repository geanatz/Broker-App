Container(
    width: double.infinity,
    height: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
        color: const Color(0xFFD9D9D9) /* popupBackground */,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
            BoxShadow(
                color: Color(0x19000000),
                blurRadius: 15,
                offset: Offset(0, 0),
                spreadRadius: 0,
            )
        ],
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Container(
                width: 296,
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
                                                        'Calculator',
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
                                ],
                            ),
                        ),
                        Container(
                            width: double.infinity,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                    Container(
                                        width: 296,
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
                                                ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: 128),
                                                    child: Container(
                                                        width: double.infinity,
                                                        height: 72,
                                                        child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            spacing: 4,
                                                            children: [
                                                                Container(
                                                                    width: double.infinity,
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
                                                                        children: [
                                                                            Expanded(
                                                                                child: Container(
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        spacing: 10,
                                                                                        children: [
                                                                                            Text(
                                                                                                'Suma',
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
                                                                        ],
                                                                    ),
                                                                ),
                                                                Container(
                                                                    width: double.infinity,
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
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                            Expanded(
                                                                                child: Container(
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'Introdu suma',
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                                    fontSize: 17,
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
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: 128),
                                                    child: Container(
                                                        width: double.infinity,
                                                        height: 72,
                                                        child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            spacing: 4,
                                                            children: [
                                                                Container(
                                                                    width: double.infinity,
                                                                    height: 21,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 8,
                                                                        children: [
                                                                            Expanded(
                                                                                child: Container(
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        spacing: 10,
                                                                                        children: [
                                                                                            Text(
                                                                                                'Dobanda',
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
                                                                        ],
                                                                    ),
                                                                ),
                                                                Container(
                                                                    width: double.infinity,
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
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                            Expanded(
                                                                                child: Container(
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'Introdu dobanda',
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                                    fontSize: 17,
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
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 72,
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 8,
                                                        children: [
                                                            Expanded(
                                                                child: ConstrainedBox(
                                                                    constraints: BoxConstraints(minWidth: 128),
                                                                    child: Container(
                                                                        height: 72,
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
                                                                            children: [
                                                                                Container(
                                                                                    width: double.infinity,
                                                                                    height: 21,
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        spacing: 8,
                                                                                        children: [
                                                                                            Expanded(
                                                                                                child: Container(
                                                                                                    clipBehavior: Clip.antiAlias,
                                                                                                    decoration: BoxDecoration(),
                                                                                                    child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                        spacing: 10,
                                                                                                        children: [
                                                                                                            Text(
                                                                                                                'Ani',
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
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Container(
                                                                                    width: double.infinity,
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
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Expanded(
                                                                                                child: Container(
                                                                                                    clipBehavior: Clip.antiAlias,
                                                                                                    decoration: BoxDecoration(),
                                                                                                    child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                        children: [
                                                                                                            Text(
                                                                                                                '0',
                                                                                                                style: TextStyle(
                                                                                                                    color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                                                    fontSize: 17,
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
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: ConstrainedBox(
                                                                    constraints: BoxConstraints(minWidth: 128),
                                                                    child: Container(
                                                                        height: 72,
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
                                                                            children: [
                                                                                Container(
                                                                                    width: double.infinity,
                                                                                    height: 21,
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        spacing: 8,
                                                                                        children: [
                                                                                            Expanded(
                                                                                                child: Container(
                                                                                                    clipBehavior: Clip.antiAlias,
                                                                                                    decoration: BoxDecoration(),
                                                                                                    child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                        spacing: 10,
                                                                                                        children: [
                                                                                                            Text(
                                                                                                                'Luni',
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
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Container(
                                                                                    width: double.infinity,
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
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Expanded(
                                                                                                child: Container(
                                                                                                    clipBehavior: Clip.antiAlias,
                                                                                                    decoration: BoxDecoration(),
                                                                                                    child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                        children: [
                                                                                                            Text(
                                                                                                                '0',
                                                                                                                style: TextStyle(
                                                                                                                    color: const Color(0xFF4D4D80) /* elementColor3 */,
                                                                                                                    fontSize: 17,
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
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        decoration: ShapeDecoration(
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
                                                    height: 48,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Rata lunara',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* elementColor2 */,
                                                                                    fontSize: 17,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Container(
                                                                width: 104,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    spacing: 10,
                                                                    children: [
                                                                        Text(
                                                                            '1,020.4',
                                                                            textAlign: TextAlign.right,
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
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 48,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Dobanda totala',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* elementColor2 */,
                                                                                    fontSize: 17,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Container(
                                                                width: 104,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    spacing: 10,
                                                                    children: [
                                                                        Text(
                                                                            '12,402.7',
                                                                            textAlign: TextAlign.right,
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
                                                        ],
                                                    ),
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 48,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Plata totala',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* elementColor2 */,
                                                                                    fontSize: 17,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Container(
                                                                width: 104,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    spacing: 10,
                                                                    children: [
                                                                        Text(
                                                                            '245,240.2',
                                                                            textAlign: TextAlign.right,
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
            ),
        ],
    ),
)

Text(
    'Calculator',
    style: TextStyle(
        color: const Color(0xFF8A8AA8) /* elementColor1 */,
        fontSize: 19,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
    ),
)
// ---
Text(
    'Suma',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
    ),
)
// ---
Text(
    'Introdu suma',
    style: TextStyle(
        color: const Color(0xFF4D4D80) /* elementColor3 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Dobanda',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
    ),
)
// ---
Text(
    'Introdu dobanda',
    style: TextStyle(
        color: const Color(0xFF4D4D80) /* elementColor3 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Ani',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
    ),
)
// ---
Text(
    '0',
    style: TextStyle(
        color: const Color(0xFF4D4D80) /* elementColor3 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Luni',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
    ),
)
// ---
Text(
    '0',
    style: TextStyle(
        color: const Color(0xFF4D4D80) /* elementColor3 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Rata lunara',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    '1,020.4',
    textAlign: TextAlign.right,
    style: TextStyle(
        color: const Color(0xFF8A8AA8) /* elementColor1 */,
        fontSize: 15,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Dobanda totala',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    '12,402.7',
    textAlign: TextAlign.right,
    style: TextStyle(
        color: const Color(0xFF8A8AA8) /* elementColor1 */,
        fontSize: 15,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Plata totala',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    '245,240.2',
    textAlign: TextAlign.right,
    style: TextStyle(
        color: const Color(0xFF8A8AA8) /* elementColor1 */,
        fontSize: 15,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)
// ---
Text(
    'Titlu',
    style: TextStyle(
        color: const Color(0xFF666699) /* elementColor2 */,
        fontSize: 17,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500,
    ),
)