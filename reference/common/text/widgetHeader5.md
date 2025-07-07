Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 16, right: 8),
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
            ),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Container(
                                    width: 26.58,
                                    height: 22.40,
                                    child: Stack(),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        ],
    ),
)