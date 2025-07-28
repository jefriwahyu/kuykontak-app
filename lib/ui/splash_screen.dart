import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Deklarasi controller untuk berbagai animasi
  late AnimationController _fadeController; // Untuk efek fade in/out
  late AnimationController _slideController; // Untuk efek sliding
  late AnimationController _scaleController; // Untuk efek scaling
  late AnimationController
      _gradientController; // Untuk animasi gradient background
  late AnimationController _exitController; // Untuk animasi keluar
  late AnimationController _textController; // Untuk animasi teks

  // Deklarasi variabel animasi
  late Animation<double> _fadeAnimation; // Animasi opacity
  late Animation<Offset> _slideAnimation; // Animasi pergerakan widget
  late Animation<double> _scaleAnimation; // Animasi perubahan ukuran
  late Animation<double> _gradientAnimation; // Animasi perubahan warna gradient
  late Animation<double> _exitFadeAnimation; // Animasi fade saat keluar
  late Animation<double> _exitScaleAnimation; // Animasi scale saat keluar
  late Animation<Offset> _textSlideAnimation; // Animasi sliding teks
  late Animation<double> _textFadeAnimation; // Animasi fade teks

  bool _isNavigating = false; // Flag untuk mencegah multiple navigation

  @override
  void initState() {
    super.initState();

    // Inisialisasi semua animation controller dengan durasi masing-masing
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Konfigurasi semua animasi dengan tween dan curve yang sesuai
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut));

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeInOut));

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeInOut));

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _textController, curve: Curves.easeOutBack));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeInOut));

    // Memulai animasi dengan urutan yang telah ditentukan
    _startAnimations();
  }

  // Fungsi untuk memulai animasi secara berurutan dengan delay
  void _startAnimations() async {
    // Animasi gradient di-loop untuk efek dinamis
    _gradientController.repeat(reverse: true);

    // Animasi logo muncul pertama dengan efek scaling
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    // Animasi teks muncul setelah logo
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Animasi button fade in muncul terakhir
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();

    // Animasi sliding untuk button
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    // Membersihkan semua controller saat widget di-dispose
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _gradientController.dispose();
    _exitController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Fungsi untuk navigasi ke halaman home dengan animasi keluar
  void _navigateToHome() async {
    if (_isNavigating) return; // Mencegah multiple navigation

    setState(() => _isNavigating = true);

    // Memainkan animasi keluar
    await _exitController.forward();

    // Navigasi ke halaman home setelah animasi selesai
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isNavigating ? _exitScaleAnimation.value : 1.0,
            child: Opacity(
              opacity: _isNavigating ? _exitFadeAnimation.value : 1.0,
              child: Stack(
                children: [
                  // Background dengan animasi gradient dinamis
                  AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.lerp(
                                const Color(0xFF1976D2),
                                const Color(0xFF42A5F5),
                                _gradientAnimation.value,
                              )!,
                              Color.lerp(
                                const Color(0xFF1565C0),
                                const Color(0xFF1976D2),
                                _gradientAnimation.value,
                              )!,
                              Color.lerp(
                                const Color(0xFF0D47A1),
                                const Color(0xFF1565C0),
                                _gradientAnimation.value,
                              )!,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Dekorasi elemen floating circle untuk efek visual
                  Positioned(
                    top: screenHeight * 0.08,
                    right: -80,
                    child: AnimatedBuilder(
                      animation: _gradientController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _gradientAnimation.value * 0.8,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // [Dekorasi circle lainnya...]

                  // Konten utama splash screen
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.12),

                          // Logo dengan animasi scale
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/KuyKontak.png',
                                width: screenWidth * 0.75,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback jika gambar tidak ditemukan
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.contacts_rounded,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Subtitle dengan animasi slide dan fade
                          SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 60),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white.withOpacity(0.18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    // [Shadow configuration...]
                                  ],
                                ),
                                child: const Text(
                                  'Simpan dan Backup Kontak Anda di Cloud',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                    height: 1.4,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Color.fromRGBO(0, 0, 0, 0.2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Bagian bawah dengan CTA button
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  // Fitur-fitur aplikasi
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildFeatureItem(
                                            Icons.speed_rounded, 'Cepat'),
                                        _buildFeatureItem(
                                            Icons.security_rounded, 'Aman'),
                                        _buildFeatureItem(
                                            Icons.auto_awesome_rounded,
                                            'Mudah'),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // Button utama dengan gradient dan efek visual
                                  Container(
                                    width: screenWidth * 0.7,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFE3F2FD)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      boxShadow: [
                                        // [Shadow configuration...]
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(25),
                                        onTap: _navigateToHome,
                                        splashColor: const Color(0xFF1976D2)
                                            .withOpacity(0.2),
                                        highlightColor: const Color(0xFF1976D2)
                                            .withOpacity(0.1),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Mulai Sekarang',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF1565C0),
                                                  letterSpacing: 0.8,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      offset:
                                                          const Offset(0, 1),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Color(0xFF1565C0),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 35),

                                  // Versi aplikasi
                                  AnimatedBuilder(
                                    animation: _fadeController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fadeAnimation.value * 0.7,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                          child: Text(
                                            'KuyKontak v1.0.0',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget builder untuk item fitur
  Widget _buildFeatureItem(IconData icon, String label) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.scale(
          scale: _textFadeAnimation.value,
          child: Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
