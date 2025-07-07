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
                            'Text',
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
)