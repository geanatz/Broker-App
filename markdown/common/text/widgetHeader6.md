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
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                    Container(
                        width: 128,
                        height: 24,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                SizedBox(
                                    width: 128,
                                    child: Text(
                                        'Date',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                            fontSize: 15,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
        ],
    ),
)