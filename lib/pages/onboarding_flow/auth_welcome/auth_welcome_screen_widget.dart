import 'package:o_b_d2_scanner_frontend/pages/onboarding_flow/auth_login/auth_login_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/onboarding_flow/auth_create/auth_create_widget.dart';
import 'package:o_b_d2_scanner_frontend/widgets/onboarding_tutorial_system.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthWelcomeScreenWidget extends StatefulWidget {
  const AuthWelcomeScreenWidget({super.key});

  static String routeName = 'auth_WelcomeScreen';
  static String routePath = '/authWelcomeScreen';

  @override
  State<AuthWelcomeScreenWidget> createState() =>
      _AuthWelcomeScreenWidgetState();
}

class _AuthWelcomeScreenWidgetState extends State<AuthWelcomeScreenWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController pageViewController;

  final List<Map<String, String>> welcomePages = [
    {
      'title': 'Welcome to Auto Fix',
      'body': 'Use Auto Fix to identify your vehicle errors and resolve them with AI guidance.',
    },
    {
      'title': 'Scan with your OBD2',
      'body': 'Connect your OBD2 for quicker insights.',
    },
    {
      'title': 'Enter your Information',
      'body': 'If you do not have an OBD2 scanner you can still ask AI.',
    },
  ];

  final List<String> carImages = [
    'https://cdn.pixabay.com/photo/2017/03/27/14/56/car-2179220_960_720.jpg',
    'https://cdn.pixabay.com/photo/2015/01/19/13/51/car-604019_960_720.jpg',
    'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
    'https://cdn.pixabay.com/photo/2015/01/19/13/51/car-604019_960_720.jpg',
    'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
    'https://cdn.pixabay.com/photo/2015/01/19/13/51/car-604019_960_720.jpg',
    'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
    'https://cdn.pixabay.com/photo/2015/01/19/13/51/car-604019_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/03/27/14/56/car-2179220_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/03/27/14/56/car-2179220_960_720.jpg',
    'https://cdn.pixabay.com/photo/2015/01/19/13/51/car-604019_960_720.jpg',
    'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d',
  ];

  @override
  void initState() {
    super.initState();
    pageViewController = PageController(initialPage: 0);
    // Remove automatic onboarding check - users should authenticate first
  }

  void _showOnboarding() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 600,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: carImages.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            carImages[index],
                            width: 120,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 670),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 230,
                      child: PageView(
                        controller: pageViewController,
                        children: List.generate(welcomePages.length, (index) {
                          final page = welcomePages[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                page['title']!,
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page['body']!,
                                textAlign: TextAlign.center,
                                style:
                                    FlutterFlowTheme.of(context).labelLarge,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(welcomePages.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pageViewController.hasClients && 
                                     pageViewController.page?.round() == index
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthLoginWidget()),
                        );
                      },
                      text: 'Login',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 60,
                        color: FlutterFlowTheme.of(context).primaryText,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .copyWith(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FFButtonWidget(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthCreateWidget()),
                        );
                      },
                      text: 'Create an Account',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 60,
                        color: FlutterFlowTheme.of(context).primaryText,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .copyWith(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        GoRouter.of(context).push('/onboarding');
                      },
                      child: Text(
                        'Take a Tour',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}