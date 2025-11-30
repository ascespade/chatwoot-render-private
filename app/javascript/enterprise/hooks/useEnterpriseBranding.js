/**
 * Enterprise Branding Composable
 * 
 * Vue 3 composable for accessing enterprise branding configuration
 * Use this in Vue components instead of directly accessing window.globalConfig
 */

import { computed } from 'vue';
import {
  getBrandingConfig,
  getLogoSource,
  getLogoThumbnail,
  getProductName,
  shouldHideFooter,
  shouldHideHelpDocs,
  isWhiteLabeled,
} from '../config/branding';

/**
 * Composable for enterprise branding
 * @returns {Object} Branding utilities and computed values
 */
export function useEnterpriseBranding() {
  const config = computed(() => getBrandingConfig());
  
  const logo = computed(() => getLogoThumbnail());
  const logoDark = computed(() => getLogoSource(true));
  const productName = computed(() => getProductName());
  const brandName = computed(() => config.value.brandName);
  
  const hideFooter = computed(() => shouldHideFooter());
  const hideHelpDocs = computed(() => shouldHideHelpDocs());
  const isWhiteLabel = computed(() => isWhiteLabeled());
  
  return {
    config,
    logo,
    logoDark,
    productName,
    brandName,
    hideFooter,
    hideHelpDocs,
    isWhiteLabel,
  };
}

export default useEnterpriseBranding;

