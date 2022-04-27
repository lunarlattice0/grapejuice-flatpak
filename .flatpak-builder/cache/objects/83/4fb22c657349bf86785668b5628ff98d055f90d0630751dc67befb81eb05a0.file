from typing import List

from grapejuice_common.hardware_info.lspci import LSPci, LSPciEntry
from grapejuice_common.hardware_info.xrandr import IXRandR, XRandRProvider


def _truncate_gpu_name(name: str, length: int = 50):
    sep = " "
    buffer = []

    def format_buffer():
        return sep.join(buffer)

    def buffer_length():
        return len(format_buffer())

    for section in name.split(sep):
        buffer.append(section)
        if buffer_length() > length:
            buffer.pop()
            break

    output_string = format_buffer()
    if len(output_string) < len(name):
        output_string += " ..."

    return output_string


def pci_entry_to_phony_xrandr_entry(index: int, entry: LSPciEntry):
    return XRandRProvider(
        index=index,
        id=index,
        cap=list(),
        crtcs=-1,
        outputs=1,
        associated_providers=-1,
        name=_truncate_gpu_name(entry.gpu_id_string)
    )


class PhonyXRandR(IXRandR):
    _providers: List[XRandRProvider]

    def __init__(self):
        lspci = LSPci()

        self._providers = list(map(lambda t: pci_entry_to_phony_xrandr_entry(*t), enumerate(lspci.graphics_cards)))
        if len(self._providers) > 1:
            self._providers[-1].cap = [
                "Sink Output",
                "Sink Offload",
                "Source Output",
                "Source Offload"
            ]

    @property
    def providers(self) -> List[XRandRProvider]:
        return self._providers


def main():
    x = PhonyXRandR()
    for provider in x.providers:
        print(provider)


if __name__ == '__main__':
    main()
