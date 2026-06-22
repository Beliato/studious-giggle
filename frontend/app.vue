<template>
  <div>
    <NuxtRouterEvents @navigate="navigateTo($event.to.path)" />
    <NuxtPage />
  </div>
</template>
