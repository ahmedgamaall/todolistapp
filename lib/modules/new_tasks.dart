import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistapp/shared/components/components.dart';
import 'package:todolistapp/shared/cubit/cubit.dart';
import 'package:todolistapp/shared/cubit/states.dart';

class NewTasks extends StatelessWidget {
  const NewTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        List tasks = AppCubit.get(context).newTasks;
        return tasksBuilder(tasks: tasks);
      },
    );
  }
}
