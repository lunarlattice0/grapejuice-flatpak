import json
import logging
import sys
from dataclasses import dataclass, asdict
from itertools import chain
from subprocess import CalledProcessError
from typing import Dict, List

from grapejuice_common.errors import HardwareProfilingError, format_exception
from grapejuice_common.hardware_info.chassis_type import is_mobile_chassis, ChassisType
from grapejuice_common.hardware_info.glx_info import GLXInfo
from grapejuice_common.hardware_info.graphics_card import GraphicsCard, GPU_VENDOR_PRIORITY, GPUVendor
from grapejuice_common.hardware_info.lspci import LSPci
from grapejuice_common.hardware_info.xrandr import XRandR, XRandRProvider
from grapejuice_common.hardware_info.xrandr_factory import xrandr_factory
from grapejuice_common.roblox_renderer import RobloxRenderer

log = logging.getLogger(__name__)


def get_prime_env(card: GraphicsCard, provider: XRandRProvider) -> Dict[str, str]:
    prime_env = {"DRI_PRIME": str(provider.index)}

    if card.vendor is GPUVendor.NVIDIA:
        prime_env = {
            **prime_env,
            "__NV_PRIME_RENDER_OFFLOAD": str(provider.index),
            "__VK_LAYER_NV_optimus": "NVIDIA_only",
            "__GLX_VENDOR_LIBRARY_NAME": "nvidia"
        }

    return prime_env


def can_prime_card(card: GraphicsCard, provider: XRandRProvider):
    is_valid_sink = provider.sink_output or provider.sink_offload

    if not is_valid_sink:
        return False

    base_glx_info_hash = hash(GLXInfo())

    try:
        primed_glx_info_hash = hash(GLXInfo(env=get_prime_env(card, provider)))

    except CalledProcessError as e:
        log.error(e)
        return False

    return base_glx_info_hash != primed_glx_info_hash


@dataclass(init=False)
class ComputeParametersState:
    xrandr: XRandR
    hardware_list: LSPci

    graphics_cards_unordered: List[GraphicsCard]
    graphics_cards_ordered: List[GraphicsCard]

    card_provider_lookup: Dict[GraphicsCard, XRandRProvider]
    can_prime_lookup: Dict[GraphicsCard, bool]

    should_prime: bool

    target_card: GraphicsCard
    use_mesa_gl_override: bool
    preferred_roblox_renderer: RobloxRenderer

    @property
    def number_of_graphics_cards(self):
        return len(self.hardware_list.graphics_cards)

    @property
    def is_multi_gpu(self):
        return self.number_of_graphics_cards > 1

    @property
    def all_cards_can_do_vulkan(self):
        return all(map(lambda card: card.can_do_vulkan, self.graphics_cards_unordered))


@dataclass
class HardwareProfile:
    graphics_id: str
    gpu_vendor_id: int
    gpu_pci_id: str
    gpu_can_do_vulkan: bool
    provider_index: int
    provider_name: str
    should_prime: bool
    use_mesa_gl_override: bool
    preferred_roblox_renderer_string: str
    is_multi_gpu: bool

    version: int = 2

    @property
    def gpu_vendor(self) -> GPUVendor:
        return GPUVendor(self.gpu_vendor_id)

    @property
    def preferred_roblox_renderer(self) -> RobloxRenderer:
        return RobloxRenderer(self.preferred_roblox_renderer_string)

    @property
    def as_dict(self) -> Dict[str, any]:
        return asdict(self)

    @property
    def as_json(self) -> str:
        return json.dumps(self.as_dict, indent=2)

    @classmethod
    def from_dict(cls, d: Dict):
        return cls(**d)

    @classmethod
    def from_json(cls, json_string: str):
        return cls.from_dict(json.loads(json_string))

    @classmethod
    def from_profiler(
        cls,
        state: ComputeParametersState
    ):
        card = state.target_card
        provider = state.card_provider_lookup.get(card)

        return cls(
            state.hardware_list.graphics_id,
            card.vendor.value,
            card.pci_id,
            card.can_do_vulkan,
            provider.index,
            provider.name,
            state.should_prime,
            state.use_mesa_gl_override,
            state.preferred_roblox_renderer.value,
            state.is_multi_gpu
        )


def _collect_information(state: ComputeParametersState):
    log.info("Getting lspci and XRandR data")

    state.xrandr = xrandr_factory()
    state.hardware_list = LSPci()

    graphics_cards = state.hardware_list.graphics_cards
    state.should_prime = state.number_of_graphics_cards > 1
    if state.number_of_graphics_cards <= 0:
        raise RuntimeError("No graphics hardware")

    state.graphics_cards_unordered = list(map(GraphicsCard, graphics_cards))
    state.graphics_cards_ordered = list(
        sorted(
            state.graphics_cards_unordered,
            key=lambda card: GPU_VENDOR_PRIORITY[card.vendor]
        )
    )

    # Let's just hope cards and providers always follow the same order here
    state.card_provider_lookup = dict(zip(state.graphics_cards_unordered, state.xrandr.providers))
    state.can_prime_lookup = dict(zip(
        state.graphics_cards_unordered,
        map(
            lambda card: can_prime_card(card, state.card_provider_lookup[card]),
            state.graphics_cards_unordered
        )
    ))

    log.info(f"Got multiple graphics cards: {state.should_prime}")


def _consider_chassis(state: ComputeParametersState):
    if state.should_prime:
        state.should_prime = is_mobile_chassis(ChassisType.local_chassis_type())


def _consider_cards_that_can_be_primed(state: ComputeParametersState):
    if state.should_prime:
        state.should_prime = any(state.can_prime_lookup.values())
        log.info(f"We can prime a graphics card: {state.should_prime}")


def _pick_target_card(state: ComputeParametersState):
    if state.number_of_graphics_cards == 1:
        log.info("There is only one graphics card installed, pick the 0th one")
        target_card = state.graphics_cards_ordered[0]

    else:
        vendor_set = list(set(map(lambda c: c.vendor, state.graphics_cards_ordered)))
        homogenous_system = len(vendor_set) == 1

        # Prepend a list of cards we can prime so they have a higher priority
        card_iter = chain(
            filter(
                lambda card: state.can_prime_lookup[card],
                state.graphics_cards_ordered
            ),
            iter(state.graphics_cards_ordered)
        )

        if homogenous_system:
            log.info("The system is homogenous in vendors just pick the first card we can prime")
            target_card = next(card_iter)

        else:
            # Only pick the first Vulkan card if *all* cards can do Vulkan
            # Odds are if not all cards can do vulkan, is that the Intel Vulkan guess is wrong

            if state.all_cards_can_do_vulkan:
                log.info("Pick the first vulkan card")  # Which we can prime
                target_card = next(filter(lambda card: card.can_do_vulkan, card_iter), state.graphics_cards_ordered[0])

            else:
                log.info("Pick first card because not all of them can do Vulkan")
                target_card = state.graphics_cards_ordered[0]

    state.target_card = target_card


def _pick_renderer(state: ComputeParametersState):
    use_mesa_gl_override = False

    if state.target_card.can_do_vulkan:
        log.info("Target card can do Vulkan, prefer vulkan")
        preferred_roblox_renderer = RobloxRenderer.Vulkan

    else:
        try:
            provider = state.card_provider_lookup.get(state.target_card, None)
            if state.should_prime and provider:
                glx_info = GLXInfo(env=get_prime_env(state.target_card, provider))

            else:
                glx_info = GLXInfo()

            # Some GPUs are so old that they do not even support a version of OpenGL high enough
            # for Roblox. In this case some mesa trickery is required.

            # Special nVidia case
            if state.target_card.vendor is GPUVendor.NVIDIA and glx_info.version == (4, 6, 0):
                log.info("Card is a wacky nVidia one, use mesa gl override")
                use_mesa_gl_override = True

            elif glx_info.version <= (4, 4):
                log.info("Card is ancient, use mesa gl override")
                use_mesa_gl_override = True

            log.info("Prefer OpenGL renderer")
            preferred_roblox_renderer = RobloxRenderer.OpenGL

        except CalledProcessError as e:
            log.error(e)
            log.info("Cannot get GL info, let Roblox decide")
            # As a last resort, use D3D11 if GL info is not available
            preferred_roblox_renderer = RobloxRenderer.Undetermined

    state.preferred_roblox_renderer = preferred_roblox_renderer
    state.use_mesa_gl_override = use_mesa_gl_override


def profile_hardware() -> HardwareProfile:
    log.info("Computing hardware profile parameters")

    try:
        state = ComputeParametersState()

        _collect_information(state)
        _consider_chassis(state)
        _consider_cards_that_can_be_primed(state)
        _pick_target_card(state)
        _pick_renderer(state)

        return HardwareProfile.from_profiler(state)

    except Exception as e:
        log.error(f"{type(e).__name__}: {str(e)}")
        log.error(format_exception(e))

        raise HardwareProfilingError(e)


if __name__ == '__main__':
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    profile = profile_hardware()
    print(profile.as_json)
