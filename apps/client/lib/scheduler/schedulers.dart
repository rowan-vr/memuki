import 'scheduler_registry.dart';
import 'steps_sm2/steps_sm2_scheduler.dart';

/// Every scheduler version the app can replay.
final allSchedulers = SchedulerRegistry([const StepsSm2Scheduler()]);
