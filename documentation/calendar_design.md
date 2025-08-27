Container(
    width: double.infinity,
    height: double.infinity,
    padding: const EdgeInsets.only(top: 24),
    decoration: ShapeDecoration(
        color: const Color(0xFFDDD7D0) /* light-general-box */,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
        ),
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                        SizedBox(
                            width: 249.60,
                            height: 24,
                            child: Text(
                                'Luni 20',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                        SizedBox(
                            width: 249.60,
                            height: 24,
                            child: Text(
                                'Marti 21',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                        SizedBox(
                            width: 249.60,
                            height: 24,
                            child: Text(
                                'Miercuri 22',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                        SizedBox(
                            width: 249.60,
                            height: 24,
                            child: Text(
                                'Joi 23',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                        SizedBox(
                            width: 249.60,
                            height: 24,
                            child: Text(
                                'Vineri 24',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ),
                    ],
                ),
            ),
            Expanded(
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            Expanded(
                                child: Container(
                                    width: double.infinity,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                            Expanded(
                                                child: Container(
                                                    height: double.infinity,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 16,
                                                        children: [
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '10:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: double.infinity,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 16,
                                                        children: [
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFECEAE8) /* light-blue-container-2 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF686663) /* light-blue-text-3 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DCD6),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '10:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                    height: double.infinity,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 16,
                                                        children: [
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '10:00',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                            ),
                                            Expanded(
                                                child: Container(
                                                    height: double.infinity,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 16,
                                                        children: [
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                    height: double.infinity,
                                                    decoration: ShapeDecoration(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 16,
                                                        children: [
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE6E5E4) /* light-blue-container-1 */,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    shadows: [
                                                                        BoxShadow(
                                                                            color: Color(0x0C503E29),
                                                                            blurRadius: 8,
                                                                            offset: Offset(0, 4),
                                                                            spreadRadius: 0,
                                                                        )
                                                                    ],
                                                                ),
                                                                child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    'Claudiu Vasile',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                                                        fontSize: 17,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 10,
                                                                            children: [
                                                                                Text(
                                                                                    '12:00',
                                                                                    textAlign: TextAlign.right,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF958F88) /* light-blue-text-1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            Container(
                                                                width: double.infinity,
                                                                height: 64,
                                                                decoration: ShapeDecoration(
                                                                    color: const Color(0xFFE1DBD5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                        Container(
                                                                            width: 48,
                                                                            height: 24,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                            ),
                                                                            child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                spacing: 10,
                                                                                children: [
                                                                                    Text(
                                                                                        '9:30',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFCAC7C3),
                                                                                            fontSize: 17,
                                                                                            fontFamily: 'Outfit',
                                                                                            fontWeight: FontWeight.w600,
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
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Container(
                width: double.infinity,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                        Container(
                            width: 480,
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFE3E1DE) /* light-general-background */,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                    ),
                                ),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 8,
                                children: [
                                    Expanded(
                                        child: Container(
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFECEAE8) /* light-blue-container-2 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                shadows: [
                                                    BoxShadow(
                                                        color: Color(0x0C503E29),
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
                                    ),
                                    SizedBox(
                                        width: 149.33,
                                        height: 24,
                                        child: Text(
                                            '20 - 24 Decembrie',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: const Color(0xFF7F7A75) /* light-blue-text-2 */,
                                                fontSize: 15,
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                    ),
                                    Expanded(
                                        child: Container(
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFECEAE8) /* light-blue-container-2 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                shadows: [
                                                    BoxShadow(
                                                        color: Color(0x0C503E29),
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