import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/ToDoListService.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ToDoListMainScreen extends StatefulWidget {
  @override
  _ToDoListMainScreenState createState() => _ToDoListMainScreenState();
}

class _ToDoListMainScreenState extends State<ToDoListMainScreen> {
  bool _showPlanned = true;
  List<Task> _plannedTasks = [];
  List<Task> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasksFromDatabase();
  }

  Future<void> _loadTasksFromDatabase() async {
    try {
      List<Task> allTasks = await ToDoListService.getTasks();

      setState(() {
        _plannedTasks = allTasks.where((task) => task.isCompleted == 0).toList();
        _completedTasks = allTasks.where((task) => task.isCompleted == 1).toList();
      });

      print('Загружено задач: ${allTasks.length}');
      print('Запланированные: ${_plannedTasks.length}');
      print('Выполненные: ${_completedTasks.length}');

    } catch (e) {
      print('Ошибка при загрузке задач из БД: $e');

      setState(() {
        _plannedTasks = [
          Task(id: 1, title: 'Сделать домашку', date: DateTime.now(), isCompleted: 0),
          Task(id: 2, title: 'Купить продукты', date: DateTime.now(), isCompleted: 0),
        ];
        _completedTasks = [
          Task(id: 3, title: 'Прочитать книгу', date: DateTime(2024, 1, 10), isCompleted: 1),
        ];
      });
    }
  }

  void _addTask(String title, DateTime date) async {
    int taskId;
    if (_showPlanned) {
      taskId = await ToDoListService.insertTask(title, date, 0);
    }
    else {
      taskId = await ToDoListService.insertTask(title, date, 1);
    }
    setState(() {
      if (_showPlanned) {
        _plannedTasks.add(Task(id: taskId, title: title, date: date, isCompleted: 0));
      } else {
        _completedTasks.add(Task(id: taskId, title: title, date: date, isCompleted: 1));
      }
    });
  }

  void _updateTask(int taskId, String newTitle, DateTime newDate) async {
    await ToDoListService.updateTask(taskId, newTitle, newDate);
    setState(() {
      if (_showPlanned) {
        final index = _plannedTasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _plannedTasks[index] =
              _plannedTasks[index].copyWith(title: newTitle, date: newDate);
        }
      } else {
        final index = _completedTasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _completedTasks[index] =
              _completedTasks[index].copyWith(title: newTitle, date: newDate);
        }
      }
    });
    ToDoListService.updateTask(taskId, newTitle, newDate);
  }

  void _deleteTask(int taskId) async {
    await ToDoListService.deleteTask(taskId);
    setState(() {
      if (_showPlanned) {
        _plannedTasks.removeWhere((task) => task.id == taskId);
      } else {
        _completedTasks.removeWhere((task) => task.id == taskId);
      }
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091E08),
      body: Column(
        children: [
          Container(
            width: 412,
            height: 85,
            color: const Color(0xFF073C00),
            child: const Center(
              child: Text(
                'To Do List',
                style: TextStyle(
                  color: Color(0xFF59FF43),
                  fontSize: 36,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPlanned = true;
                    });
                  },
                  child: Container(
                    width: 174,
                    height: 41,
                    decoration: BoxDecoration(
                      color: _showPlanned
                          ? const Color(0xFF59FF43)
                          : const Color(0xFF073C00),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF59FF43),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Запланированные',
                        style: TextStyle(
                          color: _showPlanned
                              ? const Color(0xFF073C00)
                              : const Color(0xFF59FF43),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPlanned = false;
                    });
                  },
                  child: Container(
                    width: 174,
                    height: 41,
                    decoration: BoxDecoration(
                      color: _showPlanned
                          ? const Color(0xFF073C00)
                          : const Color(0xFF59FF43),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF59FF43),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Выполненные',
                        style: TextStyle(
                          color: _showPlanned
                              ? const Color(0xFF59FF43)
                              : const Color(0xFF073C00),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: 384,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                itemCount: _showPlanned ? _plannedTasks.length : _completedTasks
                    .length,
                itemBuilder: (context, index) {
                  final task = _showPlanned
                      ? _plannedTasks[index]
                      : _completedTasks[index];
                  return _buildTaskContainer(task);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GestureDetector(
              onTap: () {
                _showAddTaskModal(context);
              },
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 30),
                child: SvgPicture.asset(
                  'assets/icons/add.svg',
                  width: 100,
                  height: 100,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTaskStatus(Task task) async {
    try {
      await ToDoListService.markTaskAsCompleted(task.id);

      setState(() {
        if (task.isCompleted == 1) {
          _completedTasks.removeWhere((t) => t.id == task.id);
          _plannedTasks.add(task.copyWith(isCompleted: 0));
        } else {
          _plannedTasks.removeWhere((t) => t.id == task.id);
          _completedTasks.add(task.copyWith(isCompleted: 1));
        }
      });
    } catch (e) {
      print('Ошибка при переключении статуса: $e');
    }
  }

  Widget _buildTaskIcon(Task task) {
    return GestureDetector(
      onTap: () {
        _toggleTaskStatus(task);
      },
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(left: 16),
        child: task.isCompleted == 1
            ? SvgPicture.asset(
          'assets/icons/ready.svg',
          width: 30,
          height: 30,
        )
            : SvgPicture.asset(
          'assets/icons/rectangle.svg',
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Widget _buildTaskContainer(Task task) {
    return Container(
      width: 384,
      height: 78,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF073C00),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2C911F),
          width: 4,
        ),
      ),
      child: Row(
        children: [
          _buildTaskIcon(task),

          Container(
            width: 250,
            height: 60,
            margin: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 28,
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Color(0xFF59FF43),
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 24,
                  child: Text(
                    _formatDate(task.date),
                    style: const TextStyle(
                      color: Color(0xFF8DFFA6),
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              _showEditTaskModal(context, task);
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10, bottom: 5),
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskModal(BuildContext context, Task task) {
    String editedTitle = task.title;
    DateTime editedDate = task.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 342,
                height: 537,
                decoration: BoxDecoration(
                  color: const Color(0xFF091E08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2C911F),
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'Изменить задачу',
                        style: TextStyle(
                          color: Color(0xFF59FF43),
                          fontSize: 24,
                        ),
                      ),
                    ),
                    _buildInputField(
                      label: 'Название задачи',
                      initialValue: task.title,
                      onChanged: (value) => editedTitle = value,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Дата выполнения (ДД.ММ.ГГГГ)',
                            style: const TextStyle(
                              color: Color(0xFF59FF43),
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: editedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  editedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF073C00),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    _formatDate(editedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF59FF43),
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildButton(
                                text: 'Удалить',
                                backgroundColor: const Color(0xFF7C0101),
                                textColor: const Color(0xFF040C03),
                                onPressed: () {
                                  _deleteTask(task.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                              _buildButton(
                                text: 'Сохранить',
                                backgroundColor: const Color(0xFF59FF43),
                                textColor: const Color(0xFF073C00),
                                onPressed: () {
                                  if (editedTitle.isNotEmpty) {
                                    _updateTask(task.id, editedTitle, editedDate);
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildButton(
                            text: 'Отмена',
                            backgroundColor: const Color(0xFF073C00),
                            textColor: const Color(0xFF59FF43),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskModal(BuildContext context) {
    String newTitle = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 342,
            height: 537,
            decoration: BoxDecoration(
              color: const Color(0xFF091E08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2C911F),
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'Добавить задачу',
                    style: TextStyle(
                      color: Color(0xFF59FF43),
                      fontSize: 24,
                    ),
                  ),
                ),

                _buildInputField(
                  label: 'Название задачи',
                  onChanged: (value) => newTitle = value,
                ),

                _buildDateField(
                  label: 'Дата выполнения (ДД.ММ.ГГГГ)',
                  initialDate: selectedDate,
                  onDateSelected: (date) => selectedDate = date,
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButton(
                            text: 'Отмена',
                            backgroundColor: const Color(0xFF073C00),
                            textColor: const Color(0xFF59FF43),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          _buildButton(
                            text: 'Добавить',
                            backgroundColor: const Color(0xFF59FF43),
                            textColor: const Color(0xFF073C00),
                            onPressed: () {
                              if (newTitle.isNotEmpty) {
                                _addTask(newTitle, selectedDate);
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                      // Добавьте отступ снизу
                      SizedBox(height: 20), // или любой другой размер
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildInputField({
    required String label,
    String initialValue = '',
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF59FF43),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF073C00),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              onChanged: onChanged,
              controller: TextEditingController(text: initialValue),
              style: const TextStyle(
                color: Color(0xFF59FF43),
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF59FF43),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != initialDate) {
                onDateSelected(picked);
              }
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF073C00),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _formatDate(initialDate),
                    style: const TextStyle(
                      color: Color(0xFF59FF43),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

extension TaskCopyWith on Task {
  Task copyWith({
    int? id,
    String? title,
    DateTime? date,
    int? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}