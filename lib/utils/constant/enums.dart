

enum TextSizes {small, medium, large}
enum OrderStatus {processing, shipped, delivered, cancelled}
enum PaymentMethod {creditCard, paypal, bankTransfer}


enum MachineStatus { operational, idle, underMaintenance, broken }
enum MachineType { printer3D, laserCutter, cnc, resinPrinter, slsPrinter, postProcessing }
enum IssuePriority { critical, high, medium, low }
enum IssueStatus { pending, inProgress, fixed }
enum ScheduleStatus { upcoming, inProgress, completed, overdue }


enum EventType { requestApproval, maintenance, meeting, machineUsage, adminTask }
enum EventStatus { pending, inProgress, completed, canceled, approved, rejected }