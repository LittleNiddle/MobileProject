import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Future<List<Map<String, dynamic>>> getBrandData() async {
    final CollectionReference brandCollection =
        FirebaseFirestore.instance.collection('ChartInfo');
    final QuerySnapshot snapshot = await brandCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return {
          'brand': data['brandName'] ?? '',
          'count': data['roomCount'] ?? 0,
        };
      }
      return {'brand': '', 'count': 0};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getMyChartData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    user = auth.currentUser;
    final CollectionReference brandCollection =
        FirebaseFirestore.instance.collection('ChartInfo');
    final QuerySnapshot snapshot = await brandCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return {
          'brand': data['brandName'] ?? '',
          'count': data['roomCount'] ?? 0,
        };
      }
      return {'brand': '', 'count': 0};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('D\'Chart')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Bar Chart'),
              tileColor: Colors.green[200],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FutureBuilder(
                  future: getBrandData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.data == null) return Text('No Data');
                      final data = snapshot.data as List<Map<String, dynamic>>;
                      final chartData = data.map((item) {
                        return {
                          'domain': item['brand'],
                          'measure': item['count']
                        };
                      }).toList();
                      return DChartBar(
                        data: [
                          {
                            'id': '브랜드',
                            'data': chartData,
                          },
                        ],
                        domainLabelPaddingToAxisLine: 16,
                        axisLineTick: 2,
                        axisLinePointTick: 2,
                        axisLinePointWidth: 10,
                        axisLineColor: Colors.green,
                        measureLabelPaddingToAxisLine: 16,
                        barColor: (barData, index, id) => Colors.green,
                        showBarValue: true,
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FutureBuilder(
                  future: getBrandData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.data == null) return Text('No Data');
                      final data = snapshot.data as List<Map<String, dynamic>>;
                      final chartData = data.map((item) {
                        return {
                          'domain': item['brand'],
                          'measure': item['count']
                        };
                      }).toList();
                      return DChartBar(
                        data: [
                          {
                            'id': '브랜드',
                            'data': chartData,
                          },
                        ],
                        domainLabelPaddingToAxisLine: 16,
                        axisLineTick: 2,
                        axisLinePointTick: 2,
                        axisLinePointWidth: 10,
                        axisLineColor: Colors.green,
                        measureLabelPaddingToAxisLine: 16,
                        barColor: (barData, index, id) => Colors.green,
                        showBarValue: true,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
