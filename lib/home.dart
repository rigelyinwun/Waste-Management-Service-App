// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class TaskHomePage extends StatefulWidget {
//   const TaskHomePage({super.key});
//
//   @override
//   State<TaskHomePage> createState() => _TaskHomePageState();
// }
//
// class _TaskHomePageState extends State<TaskHomePage> {
//   final TextEditingController taskController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance
//   // Add task to Firestore
//   void addTask() {
//     if (taskController.text.isNotEmpty) {
//       _firestore.collection('tasks').add({
//         'title': taskController.text,
//         'createdAt': Timestamp.now(),
//       });
//
//       taskController.clear();
//     }
//   }
//
//   // Delete task
//   void deleteTask(String docId) {
//     _firestore.collection('tasks').doc(docId).delete();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Firestore Task List"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: taskController,
//                     decoration: const InputDecoration(
//                       hintText: "Enter a task",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: addTask,
//                   child: const Text("Add"),
//                 ),
//               ],
//             ),
//           ),
//
//           // 🔥 Real-time Firestore List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('tasks')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState ==
//                     ConnectionState.waiting) {
//                   return const Center(
//                       child: CircularProgressIndicator());
//                 }
//
//                 if (!snapshot.hasData ||
//                     snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                       child: Text("No tasks yet"));
//                 }
//
//                 final tasks = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     var task = tasks[index];
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       child: ListTile(
//                         title: Text(task['title']),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete,
//                               color: Colors.red),
//                           onPressed: () =>
//                               deleteTask(task.id),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final TextEditingController taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addTask() {
    if (taskController.text.isNotEmpty) {
      _firestore.collection('tasks').add({
        'title': taskController.text,
        'createdAt': Timestamp.now(),
      });
      taskController.clear();
    }
  }

  void deleteTask(String docId) {
    _firestore.collection('tasks').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waste Management Tasks"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32), // Matching your theme
        // 🟢 ADDED: Sign Up button in the top right
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: "Enter a task (e.g., Collect Metal)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addTask,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  child: const Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No tasks yet"));
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(task['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(task.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}