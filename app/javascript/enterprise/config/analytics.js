/**
 * Enterprise Analytics Injection Point
 * 
 * This module provides a centralized analytics system that can be customized
 * for enterprise deployments without modifying core Chatwoot code.
 * 
 * Supported analytics providers:
 * - Google Analytics (gtag)
 * - Segment
 * - Custom analytics functions
 */

import { getBrandingConfig } from './branding';

let analyticsInitialized = false;

/**
 * Initialize analytics system
 */
export function initAnalytics() {
  if (analyticsInitialized) return;
  
  const config = getBrandingConfig();
  
  if (!config.analyticsToken && !config.analyticsProvider) {
    return;
  }
  
  // Initialize based on provider
  switch (config.analyticsProvider?.toLowerCase()) {
    case 'google':
    case 'gtag':
      initGoogleAnalytics(config.analyticsToken);
      break;
    case 'segment':
      initSegment(config.analyticsToken);
      break;
    case 'custom':
      initCustomAnalytics(config.analyticsToken);
      break;
    default:
      // Try to auto-detect Google Analytics
      if (window.gtag) {
        initGoogleAnalytics(config.analyticsToken);
      }
  }
  
  analyticsInitialized = true;
}

/**
 * Initialize Google Analytics
 */
function initGoogleAnalytics(token) {
  if (!token) return;
  
  // Load Google Analytics script if not already loaded
  if (!window.gtag) {
    const script = document.createElement('script');
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${token}`;
    document.head.appendChild(script);
    
    window.dataLayer = window.dataLayer || [];
    window.gtag = function() {
      window.dataLayer.push(arguments);
    };
    
    window.gtag('js', new Date());
    window.gtag('config', token);
  }
}

/**
 * Initialize Segment
 */
function initSegment(writeKey) {
  if (!writeKey) return;
  
  // Segment will be loaded via separate script tag in HTML
  if (window.analytics) {
    window.analytics.load(writeKey);
  }
}

/**
 * Initialize custom analytics
 * Allows injection of custom analytics function
 */
function initCustomAnalytics(token) {
  if (window.enterpriseAnalytics?.init) {
    window.enterpriseAnalytics.init(token);
  }
}

/**
 * Track page view
 * @param {string} path - Page path
 * @param {string} title - Page title
 */
export function trackPageView(path, title) {
  const config = getBrandingConfig();
  
  // Google Analytics
  if (window.gtag) {
    window.gtag('config', config.analyticsToken, {
      page_path: path,
      page_title: title,
    });
  }
  
  // Segment
  if (window.analytics) {
    window.analytics.page(title, {
      path,
    });
  }
  
  // Custom analytics
  if (window.enterpriseAnalytics?.trackPageView) {
    window.enterpriseAnalytics.trackPageView(path, title);
  }
}

/**
 * Track event
 * @param {string} eventName - Event name
 * @param {Object} properties - Event properties
 */
export function trackEvent(eventName, properties = {}) {
  // Google Analytics
  if (window.gtag) {
    window.gtag('event', eventName, properties);
  }
  
  // Segment
  if (window.analytics) {
    window.analytics.track(eventName, properties);
  }
  
  // Custom analytics
  if (window.enterpriseAnalytics?.trackEvent) {
    window.enterpriseAnalytics.trackEvent(eventName, properties);
  }
}

/**
 * Identify user
 * @param {string} userId - User ID
 * @param {Object} traits - User traits
 */
export function identifyUser(userId, traits = {}) {
  // Segment
  if (window.analytics) {
    window.analytics.identify(userId, traits);
  }
  
  // Custom analytics
  if (window.enterpriseAnalytics?.identify) {
    window.enterpriseAnalytics.identify(userId, traits);
  }
}

/**
 * Set user properties
 * @param {Object} properties - User properties
 */
export function setUserProperties(properties) {
  // Google Analytics
  if (window.gtag) {
    window.gtag('set', 'user_properties', properties);
  }
  
  // Custom analytics
  if (window.enterpriseAnalytics?.setUserProperties) {
    window.enterpriseAnalytics.setUserProperties(properties);
  }
}

export default {
  initAnalytics,
  trackPageView,
  trackEvent,
  identifyUser,
  setUserProperties,
};

