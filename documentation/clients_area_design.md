Container(
    width: double.infinity,
    height: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: ShapeDecoration(
        color: const Color(0xFFE1DBD5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
            Container(
                width: double.infinity,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 32),
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
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 4,
                                children: [
                                    Text(
                                        'Nr.',
                                        style: TextStyle(
                                            color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                            fontSize: 15,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w500,
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
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 184),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                            Text(
                                                'Nume',
                                                style: TextStyle(
                                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w500,
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
                            ),
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 136, maxWidth: 184),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Text(
                                                'Numar telefon',
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
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 136, maxWidth: 184),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Text(
                                                'Numar telefon 2',
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
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                            Text(
                                                'Varsta',
                                                style: TextStyle(
                                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w500,
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
                            ),
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                            Text(
                                                'Scor FICO',
                                                style: TextStyle(
                                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w500,
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
                            ),
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Text(
                                                'Codebitor',
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
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Text(
                                                'Referent',
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
                        ),
                        Expanded(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                            Text(
                                                'Status',
                                                style: TextStyle(
                                                    color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w500,
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
                            ),
                        ),
                        Container(
                            width: 72,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    SizedBox(
                                        width: 72,
                                        child: Text(
                                            'Actiuni',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: const Color(0xFF938F8A) /* light-blue-text-1 */,
                                                fontSize: 15,
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                        ),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                        BoxShadow(
                                            color: Color(0x14503E29),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        '1',
                                                        style: TextStyle(
                                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                            fontSize: 15,
                                                            fontFamily: 'Outfit',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 184),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            SizedBox(
                                                                width: 168,
                                                                child: Text(
                                                                    'Alex Popescu',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0744 444 444',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0772 450 332',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '67 ani',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '672',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD1EFD1),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Finalizat',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
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
                                            ),
                                        ),
                                        Container(
                                            height: double.infinity,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                        BoxShadow(
                                            color: Color(0x14503E29),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        '1',
                                                        style: TextStyle(
                                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                            fontSize: 15,
                                                            fontFamily: 'Outfit',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 184),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            SizedBox(
                                                                width: 168,
                                                                child: Text(
                                                                    'Alex Popescu',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0744 444 444',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0772 450 332',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '67 ani',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '672',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFD1DBEF),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Programat',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
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
                                            ),
                                        ),
                                        Container(
                                            height: double.infinity,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                        BoxShadow(
                                            color: Color(0x14503E29),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        '1',
                                                        style: TextStyle(
                                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                            fontSize: 15,
                                                            fontFamily: 'Outfit',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 184),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            SizedBox(
                                                                width: 168,
                                                                child: Text(
                                                                    'Alex Popescu',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0744 444 444',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0772 450 332',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '67 ani',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '672',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEFE1D1),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Amanat',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
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
                                            ),
                                        ),
                                        Container(
                                            height: double.infinity,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                        BoxShadow(
                                            color: Color(0x14503E29),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        '1',
                                                        style: TextStyle(
                                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                            fontSize: 15,
                                                            fontFamily: 'Outfit',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 184),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            SizedBox(
                                                                width: 168,
                                                                child: Text(
                                                                    'Alex Popescu',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0744 444 444',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0772 450 332',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '67 ani',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '672',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEFD1D1),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu raspunde',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
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
                                            ),
                                        ),
                                        Container(
                                            height: double.infinity,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                        BoxShadow(
                                            color: Color(0x14503E29),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                            spreadRadius: 0,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        '1',
                                                        style: TextStyle(
                                                            color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                            fontSize: 15,
                                                            fontFamily: 'Outfit',
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 184),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            SizedBox(
                                                                width: 168,
                                                                child: Text(
                                                                    'Alex Popescu',
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                        fontSize: 15,
                                                                        fontFamily: 'Outfit',
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0744 444 444',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 136, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '0772 450 332',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 104, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '67 ani',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 144),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        spacing: 10,
                                                        children: [
                                                            Text(
                                                                '672',
                                                                style: TextStyle(
                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                    fontSize: 15,
                                                                    fontFamily: 'Outfit',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 10,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Da',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
                                                                                    fontFamily: 'Outfit',
                                                                                    fontWeight: FontWeight.w500,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            ),
                                                            Expanded(
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Nu',
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
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 156, maxWidth: 200),
                                                child: Container(
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    height: 24,
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: ShapeDecoration(
                                                                        color: const Color(0xFFE6E5E4) /* light-blue-background1 */,
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                    ),
                                                                    child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        spacing: 10,
                                                                        children: [
                                                                            Text(
                                                                                'Neapelat',
                                                                                style: TextStyle(
                                                                                    color: const Color(0xFF666666) /* light-blue-text-3 */,
                                                                                    fontSize: 15,
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
                                            ),
                                        ),
                                        Container(
                                            height: double.infinity,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 10,
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
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        ],
    ),
)