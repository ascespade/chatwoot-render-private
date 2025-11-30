/**
 * Enterprise Module Entry Point
 * 
 * This file initializes all enterprise features and should be
 * imported early in the application lifecycle.
 * 
 * Import this in your main entry file before Vue app initialization.
 */

import { overrideGlobalConfig } from './injections/branding-injection';
import { initAnalytics } from './config/analytics';

/**
 * Initialize Enterprise Features
 */
export function initEnterprise() {
  // Override global config for backward compatibility
  overrideGlobalConfig();
  
  // Initialize analytics if configured
  initAnalytics();
  
  console.log('[Enterprise] Initialized enterprise features');
}

// Auto-initialize if this module is imported
if (typeof window !== 'undefined') {
  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initEnterprise);
  } else {
    initEnterprise();
  }
}

// Export all enterprise modules
export * from './config/branding';
export * from './config/analytics';
export * from './hooks/useEnterpriseBranding';
export * from './injections/branding-injection';

export default {
  initEnterprise,
};

