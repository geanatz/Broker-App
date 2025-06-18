Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
        color: const Color(0xFFC4C4D4) /* containerColor1 */,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
        ),
    ),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
            Expanded(
                child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                        ),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                            Container(
                                width: 56,
                                height: 56,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFACACD2) /* containerColor2 */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        ],
    ),
)