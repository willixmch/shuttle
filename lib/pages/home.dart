import 'package:flutter/material.dart';
import 'package:shuttle/components/shuttle_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The ReGent'),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          spacing: 12,
          children: [
            ShuttleCard(
              route: 'A 線',
              info: '由天鑽第2座開出',
              eta: '6 分鐘',
              upcomingEta: [],
            ),
            ShuttleCard(
              route: 'B 線',
              info: '由天鑽第18座開出',
              eta: '3 分鐘',
              upcomingEta: ['8 分鐘', '13 分鐘'],
            ),
            ShuttleCard(
              route: 'C 線',
              info: '由天鑽第9座開出',
              eta: '20 分鐘',
              upcomingEta: [],
            ),
            ShuttleCard(
              route: '特別班次',
              info: '由天鑽',
              eta: '55 分鐘',
              upcomingEta: [],
            ),
          ],
        ),
      ),
    );
  }
}
