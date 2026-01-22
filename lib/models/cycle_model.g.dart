// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleModelAdapter extends TypeAdapter<CycleModel> {
  @override
  final int typeId = 0;

  @override
  CycleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CycleModel(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      length: fields[2] as int?,
      ovulationOverrideDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CycleModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.length)
      ..writeByte(3)
      ..write(obj.ovulationOverrideDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomLogAdapter extends TypeAdapter<SymptomLog> {
  @override
  final int typeId = 1;

  @override
  SymptomLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomLog(
      date: fields[0] as DateTime,
      flow: fields[1] as FlowIntensity,
      painSymptoms: (fields[2] as List).cast<String>(),
      moodSymptoms: (fields[3] as List).cast<String>(),
      mood: fields[4] == null ? 3 : fields[4] as int,
      energy: fields[5] == null ? 3 : fields[5] as int,
      sleep: fields[6] == null ? 3 : fields[6] as int,
      skin: fields[7] == null ? 3 : fields[7] as int,
      libido: fields[8] == null ? 3 : fields[8] as int,
      symptoms: (fields[9] as List).cast<String>(),
      notes: fields[10] as String?,
      temperature: fields[11] as double?,
      weight: fields[12] as double?,
      hadSex: fields[13] as bool,
      protectedSex: fields[14] as bool,
      ovulationTest: fields[15] == null
          ? OvulationTestResult.none
          : fields[15] as OvulationTestResult,
      mucus: fields[16] == null
          ? CervicalMucusType.none
          : fields[16] as CervicalMucusType,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomLog obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.flow)
      ..writeByte(2)
      ..write(obj.painSymptoms)
      ..writeByte(3)
      ..write(obj.moodSymptoms)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.energy)
      ..writeByte(6)
      ..write(obj.sleep)
      ..writeByte(7)
      ..write(obj.skin)
      ..writeByte(8)
      ..write(obj.libido)
      ..writeByte(9)
      ..write(obj.symptoms)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.temperature)
      ..writeByte(12)
      ..write(obj.weight)
      ..writeByte(13)
      ..write(obj.hadSex)
      ..writeByte(14)
      ..write(obj.protectedSex)
      ..writeByte(15)
      ..write(obj.ovulationTest)
      ..writeByte(16)
      ..write(obj.mucus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CyclePhaseAdapter extends TypeAdapter<CyclePhase> {
  @override
  final int typeId = 4;

  @override
  CyclePhase read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CyclePhase.menstruation;
      case 1:
        return CyclePhase.follicular;
      case 2:
        return CyclePhase.ovulation;
      case 3:
        return CyclePhase.luteal;
      case 4:
        return CyclePhase.late;
      default:
        return CyclePhase.menstruation;
    }
  }

  @override
  void write(BinaryWriter writer, CyclePhase obj) {
    switch (obj) {
      case CyclePhase.menstruation:
        writer.writeByte(0);
        break;
      case CyclePhase.follicular:
        writer.writeByte(1);
        break;
      case CyclePhase.ovulation:
        writer.writeByte(2);
        break;
      case CyclePhase.luteal:
        writer.writeByte(3);
        break;
      case CyclePhase.late:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CyclePhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlowIntensityAdapter extends TypeAdapter<FlowIntensity> {
  @override
  final int typeId = 3;

  @override
  FlowIntensity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FlowIntensity.none;
      case 1:
        return FlowIntensity.light;
      case 2:
        return FlowIntensity.medium;
      case 3:
        return FlowIntensity.heavy;
      default:
        return FlowIntensity.none;
    }
  }

  @override
  void write(BinaryWriter writer, FlowIntensity obj) {
    switch (obj) {
      case FlowIntensity.none:
        writer.writeByte(0);
        break;
      case FlowIntensity.light:
        writer.writeByte(1);
        break;
      case FlowIntensity.medium:
        writer.writeByte(2);
        break;
      case FlowIntensity.heavy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlowIntensityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OvulationTestResultAdapter extends TypeAdapter<OvulationTestResult> {
  @override
  final int typeId = 5;

  @override
  OvulationTestResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OvulationTestResult.none;
      case 1:
        return OvulationTestResult.negative;
      case 2:
        return OvulationTestResult.positive;
      case 3:
        return OvulationTestResult.peak;
      default:
        return OvulationTestResult.none;
    }
  }

  @override
  void write(BinaryWriter writer, OvulationTestResult obj) {
    switch (obj) {
      case OvulationTestResult.none:
        writer.writeByte(0);
        break;
      case OvulationTestResult.negative:
        writer.writeByte(1);
        break;
      case OvulationTestResult.positive:
        writer.writeByte(2);
        break;
      case OvulationTestResult.peak:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvulationTestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CervicalMucusTypeAdapter extends TypeAdapter<CervicalMucusType> {
  @override
  final int typeId = 6;

  @override
  CervicalMucusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CervicalMucusType.none;
      case 1:
        return CervicalMucusType.dry;
      case 2:
        return CervicalMucusType.sticky;
      case 3:
        return CervicalMucusType.creamy;
      case 4:
        return CervicalMucusType.watery;
      case 5:
        return CervicalMucusType.eggWhite;
      default:
        return CervicalMucusType.none;
    }
  }

  @override
  void write(BinaryWriter writer, CervicalMucusType obj) {
    switch (obj) {
      case CervicalMucusType.none:
        writer.writeByte(0);
        break;
      case CervicalMucusType.dry:
        writer.writeByte(1);
        break;
      case CervicalMucusType.sticky:
        writer.writeByte(2);
        break;
      case CervicalMucusType.creamy:
        writer.writeByte(3);
        break;
      case CervicalMucusType.watery:
        writer.writeByte(4);
        break;
      case CervicalMucusType.eggWhite:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CervicalMucusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
