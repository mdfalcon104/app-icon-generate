# Changelog

## [1.1.0] - 2025-12-07

### Fixed
- **Correct Icon Sizes**: All icons now generate at exact pixel dimensions
  - Previously: Icons were 2x larger than required (e.g., 40x40 instead of 20x20)
  - Now: Perfect pixel sizes matching Apple's specifications
- **Icon-83.5@2x Assignment**: iPad Pro 12.9" icon now properly included in Contents.json
- **File Picker Dialog**: Fixed issue where file picker appeared multiple times after selecting image
- **Contents.json Structure**: Improved compatibility with Xcode's asset catalog

### Changed
- **Pixel-Perfect Resizing**: Switched to NSBitmapImageRep for exact pixel dimensions
- **Auto-Override Folders**: AppIcon.appiconset and Logo.imageset now automatically replace existing folders
- **Icon Size Format**: Support for decimal sizes (83.5pt) in Contents.json

### Technical Details
- Changed size type from Int to Double to support 83.5pt iPad Pro icon
- Implemented proper bitmap-based image resizing to avoid Retina display scaling issues
- Fixed tap gesture to prevent triggering during drag operations

## [1.0.0] - 2025-12-07

### Added
- Initial release
- Drag & drop or click to browse images
- Corner radius options: 0px, 4px, 8px, 16px, or custom value
- Generate all iOS app icon sizes (iPhone, iPad, App Store)
- Optional Logo.imageset generation
- Reveal in Finder functionality
- Beautiful macOS native UI with custom icon
