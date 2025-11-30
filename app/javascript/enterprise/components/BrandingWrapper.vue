<script setup>
/**
 * Enterprise Branding Wrapper Component
 * 
 * This component wraps the original Branding component and adds
 * enterprise white-label capabilities without modifying core Chatwoot code.
 */

import { computed } from 'vue';
import Branding from 'shared/components/Branding.vue';
import { shouldHideFooter } from '../config/branding';

const props = defineProps({
  disableBranding: {
    type: Boolean,
    default: false,
  },
});

// Check if footer should be hidden via enterprise config
const shouldHide = computed(() => {
  return props.disableBranding || shouldHideFooter();
});
</script>

<template>
  <!-- Only render if not hidden by enterprise config -->
  <Branding v-if="!shouldHide" :disable-branding="disableBranding" />
  <div v-else class="p-3" />
</template>

