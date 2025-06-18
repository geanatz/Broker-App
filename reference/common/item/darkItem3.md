Container(
    width: double.infinity,
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            'Descriere',
                            textAlign: TextAlign.right,
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