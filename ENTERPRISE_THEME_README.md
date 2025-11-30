# Enterprise Modern Purple Theme for Chatwoot 3.x

## Overview

This theme provides a complete modern UI redesign for Chatwoot 3.x using safe, non-breaking SCSS + CSS variable overrides. The theme is inspired by Linear.app's modern purple design language.

## Features

### 🎨 **Modern Purple Color Palette**
- Primary: `#6D5DFB` (Modern Purple)
- Accent: `#A48CFF`
- Success: `#4ADE80`
- Warning: `#FBBF24`
- Danger: `#F87171`

### 🎯 **Component Upgrades**
- ✅ **Buttons**: Gradient backgrounds, smooth hover animations, rounded corners (12px)
- ✅ **Cards**: Modern shadows, rounded corners (18px), hover effects
- ✅ **Sidebar**: Glass-like background with gradient, smooth animations
- ✅ **Header**: Glass effect with backdrop blur
- ✅ **Tables**: Modern styling with gradient headers
- ✅ **Tags**: Rounded pill-shaped design
- ✅ **Form Fields**: Rounded corners (12px), modern focus states
- ✅ **Modals**: Large rounded corners (24px), smooth animations
- ✅ **Dropdown Menus**: Glass effect, modern shadows

### 🎭 **UI Enhancements**
- Rounded UI elements (12px - 24px border radius)
- Smooth shadows for depth
- Modern hover animations with subtle transforms
- Glass-like sidebar background with backdrop blur
- Refreshed typography system
- Gradient effects for primary actions

## Installation

### Method 1: Import in Main SCSS File (Recommended)

Add the theme import at the **end** of `app/javascript/dashboard/assets/scss/_woot.scss`:

```scss
// ... existing imports ...

@import 'plugins/multiselect';
@import 'plugins/dropdown';

// Enterprise Modern Purple Theme (must be last to override)
@import '../../styles/enterprise-theme';
```

### Method 2: Import in app.scss

Alternatively, you can import it in `app/javascript/dashboard/assets/scss/app.scss`:

```scss
@import 'woot';

// Enterprise Modern Purple Theme
@import '../../styles/enterprise-theme';
```

### Method 3: Webpack/Build Configuration

If you're using a custom build configuration, ensure the theme file is imported after all other styles:

```javascript
// In your webpack config or entry point
import './dashboard/assets/scss/_woot.scss';
import './styles/enterprise-theme.scss'; // Must be last
```

## File Location

The theme file is located at:
```
app/javascript/styles/enterprise-theme.scss
```

## CSS Variables

The theme uses CSS variables for easy customization. You can override these in your own stylesheet:

```scss
:root {
  // Primary Colors
  --color-primary: #6D5DFB;
  --color-primary-dark: #5546E8;
  --color-primary-light: #E4E1FF;
  
  // Border Radius
  --radius-md: 12px;
  --radius-lg: 18px;
  
  // Shadows
  --shadow-md: 0 4px 20px rgba(109, 93, 251, 0.08);
}
```

## Customization

### Changing Primary Color

To change the primary color, override the CSS variables:

```scss
:root {
  --color-primary: #YOUR_COLOR;
  --color-primary-dark: #YOUR_DARK_COLOR;
  --color-primary-light: #YOUR_LIGHT_COLOR;
}
```

### Adjusting Border Radius

```scss
:root {
  --radius-md: 16px; // Default: 12px
  --radius-lg: 24px; // Default: 18px
}
```

### Modifying Shadows

```scss
:root {
  --shadow-md: 0 4px 25px rgba(109, 93, 251, 0.1);
  --shadow-lg: 0 10px 50px rgba(109, 93, 251, 0.15);
}
```

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

**Note**: The glass effect (backdrop-filter) requires modern browser support. Older browsers will gracefully degrade to solid backgrounds.

## Dark Mode

The theme includes full dark mode support. Dark mode variables are automatically applied when `body.dark` class is present:

```scss
body.dark {
  --color-bg: #0F0F1E;
  --color-surface: #1A1A2E;
  --glass-bg: rgba(26, 26, 46, 0.85);
}
```

## Non-Breaking Design

This theme is designed to be **non-breaking**:

- ✅ Uses CSS variable overrides
- ✅ Higher specificity for safe overrides
- ✅ Doesn't modify core Chatwoot SCSS files
- ✅ Can be easily disabled by removing the import
- ✅ All existing functionality remains intact

## Component Examples

### Buttons

The theme automatically styles all `.button` elements:

```html
<button class="button primary">Primary Button</button>
<button class="button secondary">Secondary Button</button>
<button class="button clear">Clear Button</button>
```

### Cards

Any element with `.card` class or conversation items will receive modern styling:

```html
<div class="card">Card Content</div>
<div class="conversation">Conversation Item</div>
```

### Utility Classes

The theme also provides utility classes:

```html
<div class="glass-effect">Glass effect container</div>
<div class="modern-card">Modern card styling</div>
<span class="gradient-text">Gradient text</span>
```

## Troubleshooting

### Theme Not Applying

1. **Check import order**: The theme file must be imported **after** all other stylesheets
2. **Clear browser cache**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. **Rebuild assets**: Run your build process again

### Specific Components Not Styled

If specific components aren't being styled:

1. Check if they use standard Chatwoot classes (`.button`, `.card`, etc.)
2. Add custom selectors to the theme file if needed
3. Use browser DevTools to inspect the component's classes

### Dark Mode Issues

If dark mode isn't working:

1. Verify `body.dark` class is present
2. Check if dark mode is enabled in Chatwoot settings
3. Ensure dark mode CSS variables are properly defined

## Performance

The theme adds minimal overhead:
- **CSS Size**: ~15KB (minified)
- **Rendering**: No JavaScript, pure CSS
- **Animations**: GPU-accelerated transforms

## Maintenance

### Updating the Theme

1. Make changes to `app/javascript/styles/enterprise-theme.scss`
2. Rebuild your assets
3. Clear browser cache
4. Test in both light and dark modes

### Version Compatibility

This theme is designed for **Chatwoot 3.x**. For older versions, you may need to adjust selectors.

## License

This theme follows the same license as Chatwoot.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Chatwoot's documentation
3. Check browser console for CSS errors

## Changelog

### v1.0.0 (Initial Release)
- Complete modern purple theme
- All component upgrades
- Dark mode support
- Non-breaking implementation

