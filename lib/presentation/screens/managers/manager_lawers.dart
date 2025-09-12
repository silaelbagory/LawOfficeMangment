import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawofficemanagementsystem/presentation/screens/managers/lawyer_action_screen.dart';
import '../../../logic/user_cubit/user_cubit.dart';
import '../../../logic/user_cubit/user_state.dart';

class MyLawyersScreen extends StatelessWidget {
  const MyLawyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Lawyers")),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            final lawyers = state.users;
            if (lawyers.isEmpty) {
              return const Center(child: Text("No lawyers found"));
            }
            return ListView.builder(
              itemCount: lawyers.length,
              itemBuilder: (context, index) {
                final lawyer = lawyers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(lawyer.name),
                    subtitle: Text(lawyer.email),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LawyerActionsScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
