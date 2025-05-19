Container(
    width: double.infinity,
    height: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
        color: const Color(0xFFD9D9D9) /* light-general-popup */,
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
                width: double.infinity,
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
                                                            color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFC4C4D4) /* light-blue-container-1 */,
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
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                'Title',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                        color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                    color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                    Container(
                                        width: double.infinity,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                'Title',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                        color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                    color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 8,
                                            children: [
                                                Expanded(
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                            'Title',
                                                                                            style: TextStyle(
                                                                                                color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                            color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                                    color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                                color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                                Expanded(
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                            'Title',
                                                                                            style: TextStyle(
                                                                                                color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                            color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                                    color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                                color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                color: const Color(0xFFC4C4D4) /* light-blue-container-1 */,
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
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                'Title',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                        color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                    color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                    Container(
                                        width: double.infinity,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                'Title',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                        color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                    color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                    Container(
                                        width: double.infinity,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                'Title',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                                                                color: const Color(0xFF8A8AA8) /* light-blue-text-1 */,
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
                                                        color: const Color(0xFFACACD2) /* light-blue-container-2 */,
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
                                                                                    color: const Color(0xFF4D4D80) /* light-blue-text-3 */,
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
                                    color: const Color(0xFFC4C4D4) /* light-blue-container-1 */,
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
                                            'Reseteaza',
                                            style: TextStyle(
                                                color: const Color(0xFF666699) /* light-blue-text-2 */,
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
                                color: const Color(0xFFC4C4D4) /* light-blue-container-1 */,
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