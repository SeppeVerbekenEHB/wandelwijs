import 'package:flutter/material.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Bomen',
      'icon': Icons.park,
      'items': [
        {'name': 'Eik', 'discovered': false, 'image': null},
        {'name': 'Beuk', 'discovered': false, 'image': null},
        {'name': 'Den', 'discovered': false, 'image': null},
        {'name': 'Berk', 'discovered': false, 'image': null},
        {'name': 'Esdoorn', 'discovered': false, 'image': null},
      ]
    },
    {
      'name': 'Dieren',
      'icon': Icons.pets,
      'items': [
        {'name': 'Konijn', 'discovered': false, 'image': null},
        {'name': 'Eekhoorn', 'discovered': false, 'image': null},
        {'name': 'Hert', 'discovered': false, 'image': null},
        {'name': 'Vos', 'discovered': false, 'image': null},
      ]
    },
    {
      'name': 'Planten',
      'icon': Icons.local_florist,
      'items': [
        {'name': 'Zonnebloem', 'discovered': false, 'image': null},
        {'name': 'Brandnetel', 'discovered': false, 'image': null},
        {'name': 'Madeliefje', 'discovered': false, 'image': null},
      ]
    },
  ];

  int _currentCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verzamelalbum',
          style: TextStyle(fontFamily: 'Feijoada', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Seamlessbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Row(
                          children: [
                            Icon(
                              _categories[index]['icon'],
                              color: _currentCategory == index
                                  ? Colors.white
                                  : Colors.green[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                fontFamily: 'Feijoada',
                                color: _currentCategory == index
                                    ? Colors.white
                                    : Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        selected: _currentCategory == index,
                        selectedColor: Colors.green[700],
                        onSelected: (bool selected) {
                          setState(() {
                            _currentCategory = selected ? index : _currentCategory;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories[_currentCategory]['items'].length,
                itemBuilder: (context, index) {
                  final item = _categories[_currentCategory]['items'][index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        item['discovered']
                            ? (item['image'] != null
                                ? Image.asset(
                                    item['image'],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.green[100],
                                    child: Icon(
                                      _categories[_currentCategory]['icon'],
                                      size: 50,
                                      color: Colors.green[700],
                                    ),
                                  ))
                            : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.lock,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.black54,
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                fontFamily: 'Feijoada',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
