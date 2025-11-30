/**
 * Enterprise Branding Configuration
 * 
 * This file provides centralized branding configuration for white-label deployments.
 * All branding hooks reference this configuration.
 * 
 * Configuration is loaded from:
 * 1. window.globalConfig (backend-provided)
 * 2. window.enterpriseConfig (optional override)
 * 3. Default fallbacks
 */

/**
 * Get branding configuration with fallbacks
 * @returns {Object} Branding configuration object
 */
export function getBrandingConfig() {
  const globalConfig = window.globalConfig || {};
  const enterpriseConfig = window.enterpriseConfig || {};
  
  return {
    // Logo URLs
    logo: enterpriseConfig.LOGO || globalConfig.LOGO || '/brand-assets/logo.svg',
    logoDark: enterpriseConfig.LOGO_DARK || globalConfig.LOGO_DARK || '/brand-assets/logo_dark.svg',
    logoThumbnail: enterpriseConfig.LOGO_THUMBNAIL || globalConfig.LOGO_THUMBNAIL || '/brand-assets/logo_thumbnail.svg',
    
    // Product/Installation Name
    productName: enterpriseConfig.PRODUCT_NAME || globalConfig.INSTALLATION_NAME || 'Chatwoot',
    brandName: enterpriseConfig.BRAND_NAME || globalConfig.BRAND_NAME || 'Chatwoot',
    
    // URLs
    brandURL: enterpriseConfig.BRAND_URL || globalConfig.BRAND_URL || 'https://www.chatwoot.com',
    widgetBrandURL: enterpriseConfig.WIDGET_BRAND_URL || globalConfig.WIDGET_BRAND_URL || 'https://www.chatwoot.com',
    
    // White-label settings
    hideFooter: enterpriseConfig.HIDE_FOOTER === 'true' || globalConfig.HIDE_FOOTER === 'true' || false,
    hidePoweredBy: enterpriseConfig.HIDE_POWERED_BY === 'true' || globalConfig.HIDE_POWERED_BY === 'true' || false,
    hideHelpDocs: enterpriseConfig.HIDE_HELP_DOCS === 'true' || globalConfig.HIDE_HELP_DOCS === 'true' || false,
    
    // Analytics
    analyticsToken: enterpriseConfig.ANALYTICS_TOKEN || globalConfig.ANALYTICS_TOKEN || null,
    analyticsProvider: enterpriseConfig.ANALYTICS_PROVIDER || globalConfig.ANALYTICS_PROVIDER || null,
    
    // Meta
    metaTitle: enterpriseConfig.META_TITLE || globalConfig.META_TITLE || null,
    metaDescription: enterpriseConfig.META_DESCRIPTION || globalConfig.META_DESCRIPTION || null,
    
    // Feature flags
    enableCustomTheme: enterpriseConfig.ENABLE_CUSTOM_THEME === 'true' || false,
    enableEnterpriseFeatures: enterpriseConfig.ENABLE_ENTERPRISE_FEATURES === 'true' || false,
  };
}

/**
 * Check if instance is white-labeled
 * @returns {boolean}
 */
export function isWhiteLabeled() {
  const config = getBrandingConfig();
  return config.hideFooter || config.hidePoweredBy || config.brandName !== 'Chatwoot';
}

/**
 * Get logo source based on dark mode
 * @param {boolean} isDark - Whether dark mode is active
 * @returns {string} Logo URL
 */
export function getLogoSource(isDark = false) {
  const config = getBrandingConfig();
  return isDark && config.logoDark ? config.logoDark : config.logo;
}

/**
 * Get thumbnail logo
 * @returns {string} Thumbnail logo URL
 */
export function getLogoThumbnail() {
  const config = getBrandingConfig();
  return config.logoThumbnail;
}

/**
 * Get product/installation name
 * @returns {string} Product name
 */
export function getProductName() {
  const config = getBrandingConfig();
  return config.productName;
}

/**
 * Check if footer branding should be hidden
 * @returns {boolean}
 */
export function shouldHideFooter() {
  const config = getBrandingConfig();
  return config.hideFooter || config.hidePoweredBy;
}

/**
 * Check if help docs link should be hidden
 * @returns {boolean}
 */
export function shouldHideHelpDocs() {
  const config = getBrandingConfig();
  return config.hideHelpDocs;
}

export default {
  getBrandingConfig,
  isWhiteLabeled,
  getLogoSource,
  getLogoThumbnail,
  getProductName,
  shouldHideFooter,
  shouldHideHelpDocs,
};

