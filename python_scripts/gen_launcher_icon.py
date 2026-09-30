"""Membuat ikon launcher Android dan Windows dari assets/icon/logo1.webp."""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets" / "icon" / "logo1.webp"

ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

ICO_SIZES = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]


def square(size: int) -> Image.Image:
    image = Image.open(SOURCE).convert("RGBA")
    width, height = image.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    image = image.crop((left, top, left + side, top + side))
    return image.resize((size, size), Image.LANCZOS)


def main() -> None:
    for folder, size in ANDROID_SIZES.items():
        target = ROOT / "android" / "app" / "src" / "main" / "res" / folder
        target.mkdir(parents=True, exist_ok=True)
        square(size).save(target / "ic_launcher.png")
        print(f"android {folder}/ic_launcher.png {size}x{size}")

    ico = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
    base = Image.open(SOURCE).convert("RGBA")
    base.save(ico, format="ICO", sizes=ICO_SIZES)
    print(f"windows {ico.name} {ICO_SIZES}")


if __name__ == "__main__":
    main()
