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
)