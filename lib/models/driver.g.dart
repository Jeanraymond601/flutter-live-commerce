// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverAdapter extends TypeAdapter<Driver> {
  @override
  final int typeId = 1;

  @override
  Driver read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Driver(
      id: fields[0] as String,
      user_id: fields[1] as String,
      seller_id: fields[2] as String,
      zone_livraison: fields[3] as String,
      disponibilite: fields[4] as bool,
      created_at: fields[5] as DateTime,
      updated_at: fields[6] as DateTime,
      user: fields[7] as User,
    );
  }

  @override
  void write(BinaryWriter writer, Driver obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user_id)
      ..writeByte(2)
      ..write(obj.seller_id)
      ..writeByte(3)
      ..write(obj.zone_livraison)
      ..writeByte(4)
      ..write(obj.disponibilite)
      ..writeByte(5)
      ..write(obj.created_at)
      ..writeByte(6)
      ..write(obj.updated_at)
      ..writeByte(7)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      full_name: fields[1] as String,
      email: fields[2] as String,
      telephone: fields[3] as String,
      adresse: fields[4] as String,
      role: fields[5] as String,
      statut: fields[6] as String,
      is_active: fields[7] as bool,
      password: fields[8] as String?,
      created_at: fields[9] as DateTime?,
      updated_at: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.full_name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.telephone)
      ..writeByte(4)
      ..write(obj.adresse)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.statut)
      ..writeByte(7)
      ..write(obj.is_active)
      ..writeByte(8)
      ..write(obj.password)
      ..writeByte(9)
      ..write(obj.created_at)
      ..writeByte(10)
      ..write(obj.updated_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
