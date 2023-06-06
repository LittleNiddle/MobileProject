import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
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
          'brand': data['brand'] ?? '',
          'count': data['count'] ?? 0,
        };
      }
      return {'brand': '', 'count': 0};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getMyChartData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? cuser = auth.currentUser;

    final CollectionReference brandCollection = FirebaseFirestore.instance
        .collection('MyChart')
        .doc(cuser!.uid)
        .collection('Brands');
    final QuerySnapshot snapshot = await brandCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return {
          'brand': data['brand'] ?? '',
          'count': data['count'] ?? 0,
        };
      }
      return {'brand': '', 'count': 0};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Column(
            children: [
              ListTile(
                title: const Text('My Chart'),
                tileColor: Colors.green[200],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FutureBuilder(
                    future: getMyChartData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        if (snapshot.data == null) return const Text('No Data');
                        final data =
                            snapshot.data as List<Map<String, dynamic>>;
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
                          axisLineColor: Colors.green,
                          measureLabelPaddingToAxisLine: 16,
                          barColor: (barData, index, id) => Colors.green,
                          verticalDirection: false,
                        );
                      }
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Ranking of DeliWith'),
                tileColor: Colors.green[200],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FutureBuilder(
                    future: getBrandData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        if (snapshot.data == null) return const Text('No Data');
                        final data =
                            snapshot.data as List<Map<String, dynamic>>;
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
                          axisLineColor: Colors.green,
                          measureLabelPaddingToAxisLine: 16,
                          barColor: (barData, index, id) => Colors.green,
                          verticalDirection: false,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
