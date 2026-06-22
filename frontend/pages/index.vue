<template>
  <div class="container mx-auto p-6">
    <h1 class="text-4xl font-bold mb-4">Studious Giggle</h1>
    <p class="text-gray-600 mb-8">WhatsApp AI Assistant for Airbnb Hosts</p>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="border rounded-lg p-6 hover:shadow-lg transition">
        <h2 class="text-2xl font-semibold mb-2">🎯 Host Dashboard</h2>
        <p class="text-gray-600 mb-4">Manage your listings, amenities, and service recommendations</p>
        <NuxtLink to="/dashboard" class="text-blue-600 font-semibold hover:underline">
          Go to Dashboard →
        </NuxtLink>
      </div>

      <div class="border rounded-lg p-6 hover:shadow-lg transition">
        <h2 class="text-2xl font-semibold mb-2">📱 WhatsApp Bot</h2>
        <p class="text-gray-600 mb-4">Guests can ask questions about your property anytime</p>
        <p class="text-sm text-gray-500">Share this code with guests: <strong>DEMO123</strong></p>
      </div>
    </div>

    <div class="mt-12 p-6 bg-blue-50 rounded-lg">
      <h3 class="text-xl font-semibold mb-2">Quick Start</h3>
      <ol class="list-decimal list-inside space-y-2 text-gray-700">
        <li>Log in to your dashboard</li>
        <li>Add information about your property</li>
        <li>Recommend local services</li>
        <li>Share your code with guests</li>
        <li>Let AI handle the questions 24/7</li>
      </ol>
    </div>
  </div>
</template>

<script setup>
// TODO: Add authentication check
</script>

<style scoped>
.container {
  max-width: 1200px;
}
</style>
