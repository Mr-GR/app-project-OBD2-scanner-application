import 'package:o_b_d2_scanner_frontend/index.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final animationsMap = <String, AnimationInfo>{};
  late PageController pageViewController;

  final List<Map<String, String>> welcomePages = [
    {
      'title': 'Welcome to Auto Fix',
      'body': 'Use Auto Fix to identify your vehicle erros and resolve them with AI guidance.',
    },
    {
      'title': 'Scan with your OBD2',
      'body': 'Connect your OBD2 for quicker insights.',
    },
    {
      'title': 'Enter Information',
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

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        loop: true,
        reverse: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeOut,
            delay: 0.0.ms,
            duration: 3200.0.ms,
            begin: Offset(0.0, -80.0),
            end: Offset(0.0, 0.0),
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 3200.0.ms,
            duration: 3200.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -80.0),
          ),
        ],
      ),
    });
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
                    child: MasonryGridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
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
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation']!),
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
                      child: smooth_page_indicator.SmoothPageIndicator(
                        controller: pageViewController,
                        count: welcomePages.length,
                        effect: smooth_page_indicator.ExpandingDotsEffect(
                          dotColor: Colors.grey,
                          activeDotColor: Colors.black,
                          expansionFactor: 3,
                          spacing: 8.0,
                          dotHeight: 8.0,
                          dotWidth: 8.0,
                        ),
                        onDotClicked: (index) {
                          pageViewController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthForgotPasswordWidget()),
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
                          MaterialPageRoute(builder: (context) => const AuthForgotPasswordWidget()),
                        );
                      },
                      text: 'Create an Account',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 60,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle: FlutterFlowTheme.of(context).titleLarge,
                        borderRadius: BorderRadius.circular(50),
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