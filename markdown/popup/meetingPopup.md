ConstrainedBox(
    constraints: BoxConstraints(minWidth: 296, minHeight: 352),
    child: Container(
        width: 360,
        height: 432,
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
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Text(
                                                                            'Alt',
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
                                                                                'Text',
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
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Text(
                                                                            'Alt',
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
                                                                                'Text',
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
                                                                        children: [
                                                                            Text(
                                                                                'Optiune',
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
                                Container(
                                    width: double.infinity,
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
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(),
                                                                                child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                        Text(
                                                                                            'Alt',
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
                                                                        color: const Color(0xFFACACD2) /* containerColor2 */,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(16),
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
                                                                                        children: [
                                                                                            Text(
                                                                                                'Optiune',
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
                                                                                        children: [
                                                                                            Text(
                                                                                                'Text',
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
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            Expanded(
                                child: Container(
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
                        ],
                    ),
                ),
            ],
        ),
    ),
)