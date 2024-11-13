import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todolistapp/shared/components/components.dart';
import 'package:todolistapp/shared/cubit/cubit.dart';
import 'package:todolistapp/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            backgroundColor: Colors.purple.shade50,
            key: cubit.scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.purple.shade900,
              title: Text(
                cubit.titles[cubit.currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (cubit.formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: cubit.titleController.text,
                      time: cubit.timeController.text,
                      date: cubit.dateController.text,
                    );
                  }
                } else {
                  cubit.titleController.text = '';
                  cubit.timeController.text = '';
                  cubit.dateController.text = '';
                  cubit.scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          padding: const EdgeInsets.all(20.0),
                          color: Colors.white,
                          child: Form(
                            key: cubit.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultTextFormField(
                                    controller: cubit.titleController,
                                    type: TextInputType.text,
                                    label: 'Task Title',
                                    prefix: Icons.title,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    }),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                defaultTextFormField(
                                    controller: cubit.timeController,
                                    type: TextInputType.none,
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Time must not be empty';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        cubit.timeController.text =
                                            value!.format(context);
                                      });
                                    }),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                defaultTextFormField(
                                    controller: cubit.dateController,
                                    type: TextInputType.none,
                                    label: 'Task Date',
                                    prefix: Icons.calendar_today,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2025-01-01'),
                                      ).then((value) {
                                        cubit.dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    }),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.purple.shade100,
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
