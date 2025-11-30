/**
 * Enterprise Branding Injection System
 * 
 * This module patches Chatwoot components at runtime to inject
 * enterprise branding without modifying core files.
 * 
 * This allows for clean upgrades while maintaining customizations.
 */

import { getLogoThumbnail, getProductName, shouldHideHelpDocs } from '../config/branding';

/**
 * Patch Vue component props/methods for branding
 * This is called during app initialization
 */
export function injectBrandingPatches() {
  // Patch will be applied via component overrides
  // See enterprise/components/ for wrapped components
}

/**
 * Get branding props to inject into components
 */
export function getBrandingProps() {
  return {
    logoSource: getLogoThumbnail(),
    installationName: getProductName(),
    hideHelpDocs: shouldHideHelpDocs(),
  };
}

/**
 * Override globalConfig for backward compatibility
 */
export function overrideGlobalConfig() {
  const brandingProps = getBrandingProps();
  
  // Ensure window.globalConfig exists
  if (!window.globalConfig) {
    window.globalConfig = {};
  }
  
  // Override with enterprise config if not already set
  if (!window.globalConfig.LOGO_THUMBNAIL) {
    window.globalConfig.LOGO_THUMBNAIL = brandingProps.logoSource;
  }
  
  if (!window.globalConfig.INSTALLATION_NAME) {
    window.globalConfig.INSTALLATION_NAME = brandingProps.installationName;
  }
}

export default {
  injectBrandingPatches,
  getBrandingProps,
  overrideGlobalConfig,
};

