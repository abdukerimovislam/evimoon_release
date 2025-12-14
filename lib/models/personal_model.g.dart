// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalModelAdapter extends TypeAdapter<PersonalModel> {
  @override
  final int typeId = 2;

  @override
  PersonalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalModel(
      energyWeights: (fields[0] as Map).cast<String, double>(),
      moodWeights: (fields[1] as Map).cast<String, double>(),
      focusWeights: (fields[2] as Map).cast<String, double>(),
      learningIterations: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.energyWeights)
      ..writeByte(1)
      ..write(obj.moodWeights)
      ..writeByte(2)
      ..write(obj.focusWeights)
      ..writeByte(3)
      ..write(obj.learningIterations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
