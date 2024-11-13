import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistapp/shared/components/components.dart';
import 'package:todolistapp/shared/cubit/cubit.dart';
import 'package:todolistapp/shared/cubit/states.dart';

class DoneTasks extends StatelessWidget {
  const DoneTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        List tasks = AppCubit.get(context).doneTasks;
        return tasksBuilder(tasks: tasks);
      },
    );
  }
}
