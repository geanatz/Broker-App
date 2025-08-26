Container(
    width: double.infinity,
    height: 144,
    padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
    decoration: ShapeDecoration(
        color: const Color(0xFFEFE5C7),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 4,
                color: const Color(0xFFE8DAB0),
            ),
            borderRadius: BorderRadius.circular(16),
        ),
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Container(
                width: double.infinity,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            height: 27,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFE8DAB0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                    Text(
                                        'Claudiu Vasile',
                                        style: TextStyle(
                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                            fontSize: 15,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(4),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFE8DAB0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Expanded(
                child: Container(
                    width: double.infinity,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Text(
                                'Galben',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF7C7A77) /* light-blue-text-2 */,
                                    fontSize: 19,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                            Text(
                                'Tigru Bengalez',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
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
)

Container(
    width: double.infinity,
    height: 144,
    padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
    decoration: ShapeDecoration(
        color: const Color(0xFFE1EFC7),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 4,
                color: const Color(0xFFD5E9AF),
            ),
            borderRadius: BorderRadius.circular(16),
        ),
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Container(
                width: double.infinity,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFD5E9AF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                    Text(
                                        'Disponibila',
                                        style: TextStyle(
                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                            fontSize: 15,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(4),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFD5E9AF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Expanded(
                child: Container(
                    width: double.infinity,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Text(
                                'Lime',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF7C7A77) /* light-blue-text-2 */,
                                    fontSize: 19,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                            Text(
                                'Acru ca lamaia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
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
)