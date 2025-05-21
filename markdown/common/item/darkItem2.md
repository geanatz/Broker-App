Container(
    width: double.infinity,
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                            Text(
                                'Titlu',
                                style: TextStyle(
                                    color: const Color(0xFF4D4D80) /* elementColor3 */,
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