Container(
    width: double.infinity,
    height: 21,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
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
                            'Titlu',
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
                                'Alt',
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
)