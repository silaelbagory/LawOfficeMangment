import 'package:flutter/material.dart';
import 'package:lawofficemanagementsystem/core/services/firestore_service.dart';
import 'package:lawofficemanagementsystem/data/models/lawyer_action_model.dart';
import 'package:lawofficemanagementsystem/data/repositories/action_repository.dart';


class LawyerActionsScreen extends StatelessWidget {
  const LawyerActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actionRepository = ActionRepository(FirestoreService());

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Lawyer Actions"),
      ),
      body: StreamBuilder<List<LawyerActionModel>>(
        stream: actionRepository.streamAllActions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final actions = snapshot.data ?? [];

          if (actions.isEmpty) {
            return const Center(
              child: Text("No actions found."),
            );
          }

          return ListView.builder(
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(action.action),
                  subtitle: Text(
                    "${action.lawyerName} • ${action.timestamp.toLocal()}",
                  ),
                  trailing: action.metadata != null
                      ? Text(action.metadata?['actionType'] ?? '')
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
