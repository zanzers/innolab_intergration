import 'package:get/get.dart';
import 'package:innolab/src/features/models/schedule_model.dart';
import 'package:innolab/src/repo/schedule_repository/schedule_repository.dart';

class ScheduleController extends GetxController {
  static ScheduleController get instance => Get.find();

  final ScheduleRepository _repo = ScheduleRepository();

  final RxList<ScheduleEvent> events = <ScheduleEvent>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  void fetchEvents() {
    isLoading.value = true;
    _repo.getScheduleEvents().listen((data) {
      events.assignAll(data);
      isLoading.value = false;
    });
  }

  Future<String> addEvent(ScheduleEvent event) async {
    return _repo.addEvent(event);
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    await _repo.updateEvent(event);
  }

  Future<void> deleteEvent(String id) async {
    await _repo.deleteEvent(id);
  }
}
