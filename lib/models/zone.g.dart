// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneAdapter extends TypeAdapter<Zone> {
  @override
  final int typeId = 3;

  @override
  Zone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Zone(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      city: fields[3] as String,
      postal_code: fields[4] as String?,
      is_active: fields[5] as bool,
      drivers_count: fields[6] as int?,
      available_drivers: fields[7] as int?,
      created_at: fields[8] as DateTime,
      updated_at: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Zone obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.postal_code)
      ..writeByte(5)
      ..write(obj.is_active)
      ..writeByte(6)
      ..write(obj.drivers_count)
      ..writeByte(7)
      ..write(obj.available_drivers)
      ..writeByte(8)
      ..write(obj.created_at)
      ..writeByte(9)
      ..write(obj.updated_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
