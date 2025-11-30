# Enterprise-Ready Smart Edition Guide

## Overview

This Chatwoot repository has been transformed into an **Enterprise-Ready Smart Edition** with:

- ✅ Complete white-label branding system
- ✅ Advanced theme override capabilities
- ✅ Enterprise analytics injection
- ✅ Upgrade-safe customization architecture
- ✅ SaaS/white-label deployment ready

## Architecture

### Directory Structure

All enterprise customizations are stored in `/app/javascript/enterprise/` to ensure clean upgrades:

```
app/javascript/enterprise/
├── config/              # Configuration modules
│   ├── branding.js      # Branding configuration
│   └── analytics.js     # Analytics setup
├── components/          # Component wrappers
│   ├── BrandingWrapper.vue
│   └── LogoWrapper.vue
├── hooks/               # Vue composables
│   └── useEnterpriseBranding.js
├── injections/          # Runtime patches
│   └── branding-injection.js
├── styles/              # Enterprise styles
│   ├── enterprise-main.scss
│   └── theme-overrides.scss
└── index.js            # Entry point & initialization
```

## Quick Start

### 1. Branding Configuration

Configure branding via backend GlobalConfig or frontend `window.enterpriseConfig`:

```javascript
// In your HTML template or initialization script
window.enterpriseConfig = {
  LOGO: '/your-logo.svg',
  LOGO_DARK: '/your-logo-dark.svg',
  LOGO_THUMBNAIL: '/your-logo-thumbnail.svg',
  PRODUCT_NAME: 'Your Product Name',
  BRAND_NAME: 'Your Brand',
  BRAND_URL: 'https://your-brand.com',
  HIDE_FOOTER: 'true',        // Hide "Powered by" footer
  HIDE_HELP_DOCS: 'true',     // Hide help docs link
};
```

### 2. Theme Customization

Edit `app/javascript/enterprise/styles/theme-overrides.scss`:

```scss
:root {
  --color-primary: #YOUR_BRAND_COLOR;
  --color-primary-dark: #YOUR_DARK_COLOR;
  --radius-md: 16px; // Adjust border radius
}
```

### 3. Analytics Setup

Configure analytics in `window.enterpriseConfig`:

```javascript
window.enterpriseConfig = {
  ANALYTICS_TOKEN: 'your-token',
  ANALYTICS_PROVIDER: 'google', // 'google', 'segment', or 'custom'
};
```

For custom analytics, implement:

```javascript
window.enterpriseAnalytics = {
  init: (token) => { /* initialize */ },
  trackPageView: (path, title) => { /* track */ },
  trackEvent: (name, props) => { /* track */ },
  identify: (userId, traits) => { /* identify */ },
};
```

### 4. Rebuild Assets

After making changes, rebuild:

```bash
# Make script executable (first time only)
chmod +x scripts/apply-enterprise-theme.sh

# Run build script
./scripts/apply-enterprise-theme.sh

# Or manually:
npm run build
```

## Configuration Options

### Branding Options

| Config Key | Description | Default |
|------------|-------------|---------|
| `LOGO` | Main logo URL | `/brand-assets/logo.svg` |
| `LOGO_DARK` | Dark mode logo | `/brand-assets/logo_dark.svg` |
| `LOGO_THUMBNAIL` | Sidebar thumbnail logo | `/brand-assets/logo_thumbnail.svg` |
| `PRODUCT_NAME` | Product/Installation name | `Chatwoot` |
| `BRAND_NAME` | Brand name | `Chatwoot` |
| `BRAND_URL` | Brand website URL | `https://www.chatwoot.com` |
| `WIDGET_BRAND_URL` | Widget branding URL | Same as `BRAND_URL` |
| `HIDE_FOOTER` | Hide "Powered by" footer | `false` |
| `HIDE_POWERED_BY` | Alias for `HIDE_FOOTER` | `false` |
| `HIDE_HELP_DOCS` | Hide help docs link in sidebar | `false` |

### Analytics Options

| Config Key | Description | Values |
|------------|-------------|--------|
| `ANALYTICS_TOKEN` | Analytics tracking token | Your token string |
| `ANALYTICS_PROVIDER` | Analytics provider | `google`, `segment`, `custom` |

### Theme Options

Edit CSS variables in `enterprise/styles/theme-overrides.scss`:

```scss
:root {
  // Primary Colors
  --color-primary: #6D5DFB;
  --color-primary-dark: #5546E8;
  --color-primary-light: #E4E1FF;
  
  // Border Radius
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 18px;
  
  // Shadows
  --shadow-md: 0 4px 20px rgba(109, 93, 251, 0.08);
  --shadow-lg: 0 10px 40px rgba(109, 93, 251, 0.12);
}
```

## Usage in Components

### Using Branding Config

```vue
<script setup>
import { useEnterpriseBranding } from '@/enterprise/hooks/useEnterpriseBranding';

const { logo, productName, hideFooter } = useEnterpriseBranding();
</script>

<template>
  <img :src="logo" :alt="productName" />
</template>
```

### Using Branding Config (Vue 2/Old Style)

```vue
<script>
import { getLogoThumbnail, getProductName } from '@/enterprise/config/branding';

export default {
  computed: {
    logo() {
      return getLogoThumbnail();
    },
    productName() {
      return getProductName();
    },
  },
};
</script>
```

### Tracking Analytics Events

```javascript
import { trackEvent, trackPageView } from '@/enterprise/config/analytics';

// Track page view
trackPageView('/dashboard', 'Dashboard');

// Track custom event
trackEvent('button_clicked', {
  button_name: 'Submit',
  page: 'dashboard',
});
```

## White-Label Deployment

### Complete White-Label Setup

1. **Configure Branding**:

```ruby
# In Rails console or seed file
InstallationConfig.find_or_create_by(name: 'LOGO').update(value: '/brand-assets/your-logo.svg')
InstallationConfig.find_or_create_by(name: 'PRODUCT_NAME').update(value: 'Your Product')
InstallationConfig.find_or_create_by(name: 'HIDE_FOOTER').update(value: 'true')
InstallationConfig.find_or_create_by(name: 'HIDE_HELP_DOCS').update(value: 'true')
```

2. **Update Logo Assets**:

Replace files in `/public/brand-assets/`:
- `logo.svg`
- `logo_dark.svg`
- `logo_thumbnail.svg`

3. **Customize Theme**:

Edit `app/javascript/enterprise/styles/theme-overrides.scss` with your brand colors.

4. **Rebuild**:

```bash
./scripts/apply-enterprise-theme.sh
```

## Upgrade Safety

### Clean Upgrade Path

The enterprise folder structure ensures clean upgrades:

1. **Core Chatwoot files remain untouched** - All customizations are in `/enterprise/`
2. **Override pattern** - Enterprise code overrides via imports/wrappers
3. **CSS cascade** - Theme files imported last, overriding base styles
4. **Component wrapping** - Enterprise components wrap core components

### Upgrading Chatwoot

1. Pull latest Chatwoot changes
2. Resolve any merge conflicts (should be minimal due to separation)
3. Rebuild assets: `./scripts/apply-enterprise-theme.sh`
4. Test enterprise customizations still work

## Advanced Customization

### Custom Component Overrides

Create wrapped components in `app/javascript/enterprise/components/`:

```vue
<!-- enterprise/components/CustomButton.vue -->
<script setup>
import { Button } from '@/dashboard/components-next/button';
import { useEnterpriseBranding } from '@/enterprise/hooks/useEnterpriseBranding';

const { config } = useEnterpriseBranding();
</script>

<template>
  <Button 
    :class="['enterprise-button']"
    v-bind="$attrs"
  >
    <slot />
  </Button>
</template>
```

Then use in your routes/views.

### Custom Analytics Implementation

Implement custom analytics handler:

```javascript
window.enterpriseAnalytics = {
  init: (token) => {
    // Initialize your analytics SDK
    console.log('Analytics initialized with token:', token);
  },
  
  trackPageView: (path, title) => {
    // Track page view
    console.log('Page view:', path, title);
  },
  
  trackEvent: (eventName, properties) => {
    // Track event
    console.log('Event:', eventName, properties);
  },
  
  identify: (userId, traits) => {
    // Identify user
    console.log('User identified:', userId, traits);
  },
  
  setUserProperties: (properties) => {
    // Set user properties
    console.log('User properties:', properties);
  },
};
```

Set in config:

```javascript
window.enterpriseConfig = {
  ANALYTICS_PROVIDER: 'custom',
  ANALYTICS_TOKEN: 'your-token',
};
```

## Troubleshooting

### Theme Not Applying

1. **Check import order** - Enterprise styles must be imported last
2. **Clear browser cache** - Hard refresh (Ctrl+Shift+R)
3. **Rebuild assets** - Run `./scripts/apply-enterprise-theme.sh`

### Branding Not Working

1. **Check config** - Verify `window.enterpriseConfig` or backend GlobalConfig
2. **Check initialization** - Ensure enterprise module is initialized early
3. **Check console** - Look for errors in browser console

### Analytics Not Tracking

1. **Check provider** - Verify `ANALYTICS_PROVIDER` is set correctly
2. **Check token** - Ensure `ANALYTICS_TOKEN` is valid
3. **Check implementation** - For custom provider, verify handler functions exist
4. **Check network** - Look for analytics requests in Network tab

## File Reference

### Core Enterprise Files

- `app/javascript/enterprise/index.js` - Entry point & initialization
- `app/javascript/enterprise/config/branding.js` - Branding configuration
- `app/javascript/enterprise/config/analytics.js` - Analytics system
- `app/javascript/enterprise/styles/enterprise-main.scss` - Main stylesheet
- `app/javascript/styles/enterprise-theme.scss` - Base theme (already created)

### Build & Scripts

- `scripts/apply-enterprise-theme.sh` - Build script
- `app/javascript/dashboard/assets/scss/_woot.scss` - Imports enterprise styles

### Documentation

- `README_ENTERPRISE.md` - This file
- `ENTERPRISE_THEME_README.md` - Theme-specific documentation

## Support

For issues or questions:

1. Check this documentation
2. Review Chatwoot's core documentation
3. Check browser console for errors
4. Review enterprise module initialization logs

## License

Enterprise features follow the same license as Chatwoot core.

