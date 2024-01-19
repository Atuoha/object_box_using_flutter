import 'package:objectbox/objectbox.dart';

@Entity()
class Receipt {
  @Id()
  int id;
  final int amount;
  final customer = ToOne<Customer>();

  Receipt({
    this.id = 0,
    required this.amount,
  });
}

@Entity()
class Customer {
  @Id()
  int id;
  final String name;
  final String company;
  @Backlink()
  final orders = ToMany<Receipt>();

  Customer({
    this.id = 0,
    required this.name,
    required this.company,
  });
}
