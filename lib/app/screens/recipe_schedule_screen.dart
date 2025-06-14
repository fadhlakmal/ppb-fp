import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/models/recipe_schedule_model.dart';
import 'package:myapp/app/services/recipe_schedule_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final RecipeScheduleService _scheduleService = RecipeScheduleService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Schedule'), centerTitle: true),
      body:
          _auth.currentUser == null
              ? _buildNotLoggedInView()
              : _buildScheduleList(),
      floatingActionButton:
          _auth.currentUser != null
              ? FloatingActionButton(
                onPressed: () => _showAddRecipeScheduleDialog(context),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Please login to view your scheduled recipes',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return StreamBuilder<List<RecipeScheduleModel>>(
      stream: _scheduleService.getScheduledRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No scheduled recipes yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the + button to schedule a recipe',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: schedules.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  schedule.recipeTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(schedule.scheduleDateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('HH:mm').format(schedule.scheduleDateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.reminderMessage,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: schedule.isActive,
                      onChanged: (value) {
                        _scheduleService.toggleRecipeActive(schedule);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, schedule);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  _showEditRecipeScheduleDialog(context, schedule);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddRecipeScheduleDialog(
    BuildContext context, {
    String? initialTitle,
    String? initialMessage,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) async {
    final TextEditingController titleController = TextEditingController(
      text: initialTitle ?? '',
    );
    final TextEditingController messageController = TextEditingController(
      text: initialMessage ?? '',
    );

    DateTime selectedDate = initialDate ?? DateTime.now();
    TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Schedule a Recipe'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title',
                      hintText: 'Enter recipe name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null && context.mounted) {
                        Navigator.of(context).pop();
                        _showAddRecipeScheduleDialog(
                          context,
                          initialTitle: titleController.text,
                          initialMessage: messageController.text,
                          initialDate: DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          ),
                          initialTime: selectedTime,
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (pickedTime != null && context.mounted) {
                        Navigator.of(context).pop();
                        _showAddRecipeScheduleDialog(
                          context,
                          initialTitle: titleController.text,
                          initialMessage: messageController.text,
                          initialDate: DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          ),
                          initialTime: pickedTime,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Message',
                      hintText: 'Optional notification message',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a recipe title'),
                      ),
                    );
                    return;
                  }

                  final schedule = RecipeScheduleModel(
                    recipeId: DateTime.now().millisecondsSinceEpoch.toString(),
                    recipeTitle: titleController.text.trim(),
                    scheduleDateTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    reminderMessage:
                        messageController.text.trim().isEmpty
                            ? 'Time to cook ${titleController.text.trim()}!'
                            : messageController.text.trim(),
                  );

                  _scheduleService.scheduleRecipe(schedule);
                  Navigator.pop(context);
                },
                child: const Text('Schedule'),
              ),
            ],
          ),
    );
  }

  Future<void> _showEditRecipeScheduleDialog(
    BuildContext context,
    RecipeScheduleModel schedule, {
    String? initialTitle,
    String? initialMessage,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) async {
    final TextEditingController titleController = TextEditingController(
      text: initialTitle ?? schedule.recipeTitle,
    );
    final TextEditingController messageController = TextEditingController(
      text: initialMessage ?? schedule.reminderMessage,
    );

    DateTime selectedDate = initialDate ?? schedule.scheduleDateTime;
    TimeOfDay selectedTime =
        initialTime ??
        TimeOfDay(
          hour: schedule.scheduleDateTime.hour,
          minute: schedule.scheduleDateTime.minute,
        );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Recipe Schedule'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title',
                      hintText: 'Enter recipe name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null && context.mounted) {
                        Navigator.of(context).pop();
                        _showEditRecipeScheduleDialog(
                    context,
                    schedule,
                    initialTitle: titleController.text,
                    initialMessage: messageController.text,
                    initialDate: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    ),
                    initialTime: pickedTime,
                  );
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (pickedTime != null && context.mounted) {
                        Navigator.of(context).pop();
                        _showEditRecipeScheduleDialog(context, schedule);
                        selectedTime = pickedTime;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Message',
                      hintText: 'Optional notification message',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a recipe title'),
                      ),
                    );
                    return;
                  }

                  final updatedSchedule = schedule.copyWith(
                    recipeTitle: titleController.text.trim(),
                    scheduleDateTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    reminderMessage:
                        messageController.text.trim().isEmpty
                            ? 'Time to cook ${titleController.text.trim()}!'
                            : messageController.text.trim(),
                  );

                  _scheduleService.updateScheduledRecipe(updatedSchedule);
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    RecipeScheduleModel schedule,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: Text(
              'Are you sure you want to delete the schedule for "${schedule.recipeTitle}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _scheduleService.deleteScheduledRecipe(schedule.id);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
