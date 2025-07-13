Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.black),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
            Container(
                width: 360,
                height: 800,
                padding: const EdgeInsets.only(
                    top: 32,
                    left: 16,
                    right: 16,
                    bottom: 16,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                    color: const Color(0xFF3A3935),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                    ),
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                        Expanded(
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFF403E3A) /* popupBackground */,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                    ),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 288,
                                            height: 24,
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
                                                                        'Apeluri',
                                                                        style: TextStyle(
                                                                            color: const Color(0xFFA39E8E),
                                                                            fontSize: 19,
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
                                        Expanded(
                                            child: Container(
                                                width: double.infinity,
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
                                                    spacing: 8,
                                                    children: [
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                                spacing: 16,
                                                                children: [
                                                                    Expanded(
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 80,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                                            decoration: ShapeDecoration(
                                                                color: const Color(0xFFC4C4D4) /* containerColor1 */,
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
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 80,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                                            decoration: ShapeDecoration(
                                                                color: const Color(0xFFC4C4D4) /* containerColor1 */,
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
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 80,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                                            decoration: ShapeDecoration(
                                                                color: const Color(0xFFC4C4D4) /* containerColor1 */,
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
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                                                        Container(
                                                            width: double.infinity,
                                                            height: 64,
                                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                                            decoration: ShapeDecoration(
                                                                color: const Color(0xFFC4C4D4) /* containerColor1 */,
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
                                                                        child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            spacing: 4,
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
                                                                                Text(
                                                                                    'Descriere',
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF8A8AA8) /* elementColor1 */,
                                                                                        fontSize: 15,
                                                                                        fontFamily: 'Outfit',
                                                                                        fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                ),
                                                                            ],
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
                            width: 256,
                            height: 64,
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                                color: const Color(0xFF403E3A) /* popupBackground */,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                ),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                    Container(
                                        width: 48,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                            color: const Color(0xFFACACD2) /* containerColor2 */,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        width: 48,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                            color: const Color(0xFFC4C4D4) /* containerColor1 */,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        width: 48,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                            color: const Color(0xFFC4C4D4) /* containerColor1 */,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
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
)