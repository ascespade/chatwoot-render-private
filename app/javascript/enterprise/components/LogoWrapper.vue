<script setup>
/**
 * Enterprise Logo Wrapper Component
 * 
 * Wraps the logo component to allow dynamic logo replacement
 * without modifying core Chatwoot components.
 */

import { computed } from 'vue';
import { getLogoThumbnail, getProductName } from '../config/branding';

const props = defineProps({
  accountId: {
    type: Number,
    default: 0,
  },
  // Allow override via prop, but fall back to enterprise config
  source: {
    type: String,
    default: null,
  },
  name: {
    type: String,
    default: null,
  },
});

const logoSource = computed(() => {
  return props.source || getLogoThumbnail();
});

const installationName = computed(() => {
  return props.name || getProductName();
});

const dashboardPath = computed(() => {
  if (!props.accountId) return '/';
  return `/app/accounts/${props.accountId}/dashboard`;
});
</script>

<template>
  <div class="w-8 h-8">
    <router-link :to="dashboardPath" replace>
      <img :src="logoSource" :alt="installationName" />
    </router-link>
  </div>
</template>

