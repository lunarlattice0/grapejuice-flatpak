from enum import Enum
from pathlib import Path


class ChassisType(Enum):
    Other = 1
    Unknown = 2
    Desktop = 3
    LowProfileDesktop = 4
    PizzaBox = 5
    MiniTower = 6
    Tower = 7
    Portable = 8
    Laptop = 9
    Notebook = 10
    HandHeld = 11
    DockingStation = 12
    AllInOne = 13
    SubNotebook = 14
    SpaceSaving = 15
    LunchBox = 16
    MainServerChassis = 17
    ExpansionChassis = 18
    SubChassis = 19
    BusExpansionChassis = 20
    PeripheralChassis = 21
    RAIDChassis = 22
    RackMountChassis = 23
    SealedCasePC = 24
    MultiSystemChassis = 25
    CompactPCI = 26
    AdvancedTCA = 27
    Blade = 28
    BladeEnclosure = 29
    Tablet = 30
    Convertible = 31
    Detachable = 32
    IoTGateway = 33
    EmbeddedPC = 34
    MiniPC = 35
    StickPC = 36

    @classmethod
    def local_chassis_type(cls) -> "ChassisType":
        dmi_path = Path("/sys/class/dmi/id/chassis_type")

        if not dmi_path.exists():
            return cls.Unknown

        with dmi_path.open("r") as fp:
            raw_chassis_type = fp.readline().strip()

        try:
            chassis_type_int = int(raw_chassis_type)
            return cls(chassis_type_int)

        except ValueError:
            return cls.Unknown


mobile_chassis = (
    ChassisType.Laptop,
    ChassisType.Notebook,
    ChassisType.HandHeld,
    ChassisType.AllInOne,
    ChassisType.SubNotebook,
    ChassisType.SpaceSaving,
    ChassisType.Tablet,
    ChassisType.Convertible,
    ChassisType.EmbeddedPC,
    ChassisType.MiniPC,
    ChassisType.Portable,
    ChassisType.LowProfileDesktop  # Consider beefed up office PCs
)


def is_mobile_chassis(chassis: ChassisType) -> bool:
    return chassis in mobile_chassis
