Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Container(
                width: 360,
                height: 800,
                padding: const EdgeInsets.only(
                    top: 48,
                    left: 16,
                    right: 16,
                    bottom: 24,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                    color: const Color(0xFFE8E3E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                    ),
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 24,
                    children: [
                        Expanded(
                            child: Container(
                                width: double.infinity,
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                    ),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 24,
                                    children: [
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
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                spacing: 10,
                                                                children: [
                                                                    Text(
                                                                        'Clienti',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFFC17099),
                                                                            fontSize: 24,
                                                                            fontFamily: 'Urbanist',
                                                                            fontWeight: FontWeight.w700,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                width: double.infinity,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 16,
                                                    children: [
                                                        Container(
                                                            width: double.infinity,
                                                            child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                spacing: 8,
                                                                children: [
                                                                    Container(
                                                                        width: double.infinity,
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                        height: 64,
                                                                        padding: const EdgeInsets.only(left: 8, right: 24),
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFE5DCE0),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            spacing: 16,
                                                                            children: [
                                                                                Container(
                                                                                    width: 48,
                                                                                    height: 48,
                                                                                    decoration: ShapeDecoration(
                                                                                        color: const Color(0xFFC17099),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(24),
                                                                                        ),
                                                                                    ),
                                                                                    child: Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                            Text(
                                                                                                'RV',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                    color: const Color(0xFFF5D6D6),
                                                                                                    fontSize: 18,
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontWeight: FontWeight.w900,
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Container(
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                                                        child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            spacing: 4,
                                                                                            children: [
                                                                                                Text(
                                                                                                    'Nume client',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFC17099),
                                                                                                        fontSize: 18,
                                                                                                        fontFamily: 'Urbanist',
                                                                                                        fontWeight: FontWeight.w700,
                                                                                                    ),
                                                                                                ),
                                                                                                Text(
                                                                                                    'numar telefon',
                                                                                                    style: TextStyle(
                                                                                                        color: const Color(0xFFA88999),
                                                                                                        fontSize: 16,
                                                                                                        fontFamily: 'Urbanist',
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
                                                                ],
                                                            ),
                                                        ),
                                                        Container(
                                                            width: 312,
                                                            height: 72,
                                                            padding: const EdgeInsets.only(left: 8, right: 24),
                                                            decoration: ShapeDecoration(
                                                                gradient: LinearGradient(
                                                                    begin: Alignment(0.00, 0.00),
                                                                    end: Alignment(1.00, 1.03),
                                                                    colors: [const Color(0xFFE0D0D9), const Color(0xFFE2CED9), const Color(0xFFE0D1D9)],
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(40),
                                                                ),
                                                            ),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                spacing: 16,
                                                                children: [
                                                                    Container(
                                                                        width: 56,
                                                                        height: 56,
                                                                        decoration: ShapeDecoration(
                                                                            color: const Color(0xFFC17099),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(32),
                                                                            ),
                                                                        ),
                                                                        child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                                Text(
                                                                                    'RV',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFFF5D6D6),
                                                                                        fontSize: 18,
                                                                                        fontFamily: 'Urbanist',
                                                                                        fontWeight: FontWeight.w900,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ),
                                                                    Expanded(
                                                                        child: Container(
                                                                            height: 56,
                                                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                                                            child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                spacing: 4,
                                                                                children: [
                                                                                    Text(
                                                                                        'Nume client',
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFC17099),
                                                                                            fontSize: 18,
                                                                                            fontFamily: 'Urbanist',
                                                                                            fontWeight: FontWeight.w700,
                                                                                        ),
                                                                                    ),
                                                                                    Text(
                                                                                        'numar telefon',
                                                                                        style: TextStyle(
                                                                                            color: const Color(0xFFA88999),
                                                                                            fontSize: 16,
                                                                                            fontFamily: 'Urbanist',
                                                                                            fontWeight: FontWeight.w600,
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
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Container(
                            width: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                                color: const Color(0xFFE0D1D8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                ),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                    Container(
                                        width: 56,
                                        height: double.infinity,
                                        decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 4,
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
                                        width: 56,
                                        height: 56,
                                        padding: const EdgeInsets.all(8),
                                        decoration: ShapeDecoration(
                                            color: const Color(0xFFC17099),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(40),
                                            ),
                                        ),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 4,
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
                                        width: 56,
                                        height: double.infinity,
                                        decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 4,
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
)