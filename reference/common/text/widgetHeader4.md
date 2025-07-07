Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
            Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                    'Titlu',
                                    style: TextStyle(
                                        color: const Color(0xFF666699) /* elementColor2 */,
                                        fontSize: 19,
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                            ],
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                    'Descriere',
                                    style: TextStyle(
                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                        fontSize: 17,
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
)