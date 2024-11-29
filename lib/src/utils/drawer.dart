/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';



class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.routeNames,
  });

  final String routeNames;

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: const Color(0xffF9E8D9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Color(0xffEC2B28),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/person.png',
                    package: 'holoo',
                    scale: 11,
                  ),
                  const Spacer(),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xffF7B787),
                    ),
                    child: _mainButtons(context),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _customer(context),
                _product(context),
                _payment(),
                _reports(),
                _about(),
              ],
            ),
          ],
        ),
      );

  Widget _mainButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => context.push(RouteNames.homePage),
            icon: const Icon(Icons.home),
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.settings),
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.dark_mode),
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(Icons.language),
          ),
          IconButton(
            onPressed: () => context.push(RouteNames.loginPage),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      );

  Widget _customer(BuildContext context) => ExpansionTile(
        leading: const Icon(Icons.person_pin_outlined),
        title: Text(
          "مشتری",
          style: _buildTextStyle(),
        ),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ListTile(
            selected: RouteNames.customerListPage == routeNames,
            selectedColor: const Color(0xffEC2B28),
            leading: const Icon(Icons.person),
            title: Text(
              "لیست مشتری ها",
              style: _buildTextStyle(),
            ),
            onTap: () {
              context.push( RouteNames.customerListPage);
            },
            hoverColor: Colors.white,
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: Text(
              "ثبت مشتری",
              style: _buildTextStyle(),
            ),
            onTap: null,
            hoverColor: Colors.white,
          )
        ],
      );

  Widget _product(BuildContext context) => ExpansionTile(
        leading: const Icon(Icons.category),
        title: Text(
          "محصولات",
          style: _buildTextStyle(),
        ),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ListTile(
            selectedColor: const Color(0xffEC2B28),
            leading: const Icon(Icons.category_outlined),
            title: Text(
              "لیست محصولات",
              style: _buildTextStyle(),
            ),
            onTap: () {
              context.push(RouteNames.productListPage);
            },
            hoverColor: Colors.white,
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(
              "ثبت محصول",
              style: _buildTextStyle(),
            ),
            onTap: null,
            hoverColor: Colors.white,
          )
        ],
      );

  Widget _payment() => ExpansionTile(
        leading: const Icon(Icons.monetization_on),
        title: Text(
          "مالی",
          style: _buildTextStyle(),
        ),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [],
      );

  Widget _reports() => ExpansionTile(
        leading: const Icon(Icons.info_outline),
        title: Text(
          "گزارشات",
          style: _buildTextStyle(),
        ),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ListTile(
            selectedColor: const Color(0xffEC2B28),
            leading: const Icon(Icons.credit_card),
            title: Text(
              "گزارش حساب های بانکی",
              style: _buildTextStyle(),
            ),
            onTap: null,
            hoverColor: Colors.white,
          ),
          ListTile(
            leading: const Icon(Icons.percent_rounded),
            title: Text(
              "گزارش محصولات",
              style: _buildTextStyle(),
            ),
            onTap: null,
            hoverColor: Colors.white,
          )
        ],
      );

  Widget _about() => ListTile(
        leading: const Icon(Icons.info),
        title: Text(
          "در باره ما",
          style: _buildTextStyle(),
        ),
        subtitle: const Row(
          children: [Text('نسخه : 0.1')],
        ),
        onTap: null,
        hoverColor: Colors.white,
      );

  TextStyle _buildTextStyle() => const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      );
}
*/
