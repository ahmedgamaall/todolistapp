import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolistapp/modules/archived_tasks.dart';
import 'package:todolistapp/modules/done_tasks.dart';
import 'package:todolistapp/modules/new_tasks.dart';
import 'package:todolistapp/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  int currentIndex = 0;
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  List<Widget> screens = [
    const NewTasks(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() async {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {})
          .catchError((e) {
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) async {
      await txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((e) {
      });
      return null;
    });
  }

  void getDataFromDatabase(database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateDate({required String status, required int id}) async {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      emit(AppUpdateDatabaseState());
      getDataFromDatabase(database);
    });
  }

  void deleteDate({required int id}) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      emit(AppDeleteDatabaseState());
      getDataFromDatabase(database);
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
