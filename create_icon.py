#!/usr/bin/env python3
"""
Create a beautiful app icon for the App Icon Generator
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon():
    # Create a high-resolution icon
    size = 1024
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient-like background with rounded corners
    # Main background - iOS blue gradient
    radius = 180
    
    # Draw base rounded rectangle with gradient effect
    for i in range(5):
        offset = i * 15
        alpha = 255 - (i * 30)
        color = (0, 122 - i*10, 255 - i*10, alpha)
        draw.rounded_rectangle(
            [(offset, offset), (size-offset, size-offset)], 
            radius=radius-offset, 
            fill=color
        )
    
    # Draw main blue rounded rectangle
    draw.rounded_rectangle(
        [(20, 20), (size-20, size-20)], 
        radius=radius, 
        fill=(0, 122, 255, 255)
    )
    
    # Add a lighter overlay for depth
    overlay_color = (80, 180, 255, 100)
    draw.rounded_rectangle(
        [(20, 20), (size-20, size//2)], 
        radius=radius, 
        fill=overlay_color
    )
    
    # Draw white icon elements
    # Photo/Image symbol
    icon_size = 400
    icon_x = (size - icon_size) // 2
    icon_y = (size - icon_size) // 2 - 50
    
    # Draw a simplified photo icon
    # Rectangle for photo frame
    frame_thickness = 40
    draw.rounded_rectangle(
        [(icon_x, icon_y), (icon_x + icon_size, icon_y + icon_size)],
        radius=40,
        outline=(255, 255, 255, 255),
        width=frame_thickness
    )
    
    # Draw a circle (sun) in top right of frame
    sun_radius = 60
    sun_x = icon_x + icon_size - 120
    sun_y = icon_y + 100
    draw.ellipse(
        [(sun_x - sun_radius, sun_y - sun_radius), 
         (sun_x + sun_radius, sun_y + sun_radius)],
        fill=(255, 255, 255, 255)
    )
    
    # Draw mountain shapes at bottom
    mountain_points = [
        (icon_x + 50, icon_y + icon_size - 50),
        (icon_x + 150, icon_y + 200),
        (icon_x + 250, icon_y + icon_size - 50),
    ]
    draw.polygon(mountain_points, fill=(255, 255, 255, 255))
    
    mountain_points2 = [
        (icon_x + 200, icon_y + icon_size - 50),
        (icon_x + 280, icon_y + 250),
        (icon_x + 360, icon_y + icon_size - 50),
    ]
    draw.polygon(mountain_points2, fill=(255, 255, 255, 255))
    
    # Add small sparkle/star for "generator" concept
    star_x = icon_x + icon_size + 80
    star_y = icon_y - 40
    star_size = 60
    
    # Draw a plus/sparkle shape
    draw.rectangle(
        [(star_x - star_size//6, star_y - star_size),
         (star_x + star_size//6, star_y + star_size)],
        fill=(255, 220, 100, 255)
    )
    draw.rectangle(
        [(star_x - star_size, star_y - star_size//6),
         (star_x + star_size, star_y + star_size//6)],
        fill=(255, 220, 100, 255)
    )
    
    # Save the main icon
    img.save('/tmp/app_icon_base.png')
    print("✓ Created base icon")
    
    return img

def create_iconset(base_img):
    """Create all required icon sizes for macOS"""
    iconset_dir = '/tmp/AppIcon.iconset'
    os.makedirs(iconset_dir, exist_ok=True)
    
    sizes = [
        (16, 'icon_16x16.png'),
        (32, 'icon_16x16@2x.png'),
        (32, 'icon_32x32.png'),
        (64, 'icon_32x32@2x.png'),
        (128, 'icon_128x128.png'),
        (256, 'icon_128x128@2x.png'),
        (256, 'icon_256x256.png'),
        (512, 'icon_256x256@2x.png'),
        (512, 'icon_512x512.png'),
        (1024, 'icon_512x512@2x.png'),
    ]
    
    for size, filename in sizes:
        resized = base_img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(iconset_dir, filename))
    
    print(f"✓ Created iconset with {len(sizes)} sizes")
    return iconset_dir

if __name__ == '__main__':
    print("🎨 Creating beautiful app icon...")
    base_icon = create_icon()
    iconset_path = create_iconset(base_icon)
    print(f"✓ Iconset ready at: {iconset_path}")
    print("Run: iconutil -c icns /tmp/AppIcon.iconset")
