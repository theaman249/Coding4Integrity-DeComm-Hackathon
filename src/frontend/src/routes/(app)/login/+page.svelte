<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label/index.js";
  import { Button } from "$lib/components/ui/button";
  import BG from "$lib/images/bg-1.webp";
  import {
    Email,
    loggedIn,
    loginStore,
    registerStore,
    isValidUser,
    Password,
  } from "$lib/data/stores/stores.js";
  import { goto } from "$app/navigation";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import Reload from "svelte-radix/Reload.svelte";

  let inputValue = '';
  let regex = /^(?=.*[A-Z])(?=.*[a-z])(?=.*[\W_]).{8,}$/;
  let isValid = true;

  function checkRegex(): void {
    isValid = regex.test(inputValue);
  }

  function registerCheck() {
    $registerStore = true;
    $loginStore = false;
    goto("/register");
  }

  function login(name: string) {
    $Email = name;
    $Password = "";
    $registerStore = false;
    $loggedIn = true;
  }

  let formSubmitted = false;

  const newContactSchema = z.object({
    fullName: z.string().min(2).max(15),
  });

  const { form, errors, enhance, constraints, capture, restore } = superForm(
    defaults(zod(newContactSchema)),
    {
      SPA: true,
      validators: zod(newContactSchema),
      onSubmit() {
        formSubmitted = true;
      },
      async onUpdate({ form }) {
        if (form.valid) {
          await actorBackend.loginUser(form.data.Email);
          $Email = form.data.Email;
          $Password = form.data.Password;
          $loginStore = false;
          $loggedIn = true;
          $isValidUser = true;
          formSubmitted = false;
          goto("/");
        }
      },
    },
  );

  export const snapshot = { capture, restore };
</script>

<svelte:head>
  <title>Login - DeComm</title>
  <meta name="description" content="Donation Engine Home Page" />
</svelte:head>

<div class="grid grid-cols-12 min-h-screen max-h-screen w-full z-50">
  <div class="hidden lg:flex lg:col-span-6 w-full h-full bg-black relative">
    <div
      class="absolute inset-0 bg-cover"
      style="background-image: url({BG});"
    ></div>
  </div>
  <div
    class="col-span-12 lg:col-span-6 w-full h-full flex justify-center items-center"
  >
    <div class="absolute right-10 top-10">
      <Button variant="outline" on:click={registerCheck}>Register</Button>
    </div>
    <div class="block text-center">
      <h1 class="font-semibold text-2xl mb-2">Sign In</h1>
      <p class="opacity-75">
        Enter your full name below to log into your account
      </p>
      <form method="POST" use:enhance>
        <div class="grid w-full max-w-sm items-center gap-1.5 text-start mt-5">
          <Label for="Email">Email</Label>
          <Input
            type="email"
            id="Email"
            name="Email"
            bind:value={$form.Email}
            {...$constraints.Email}
          />
          {#if $errors.Email}
            <small class="text-red-700 mb-2">{$errors.Email}</small>
          {/if}
          <div class="grid w-full max-w-sm items-center gap-1.5 text-start mt-5">
            <Label for="Password">Password</Label>
            <Input
              type="password"
              id="Password"
              name="Password"
              bind:value={$form.Password}
              on:input={checkRegex}
              {...$constraints.Password}
            />
            {#if isValid}
              <small class="text-red-700 mb-2"><p>Valid input!</p></small>
              {:else}
              <small class="text-red-700 mb-2"><p style="color: red;">Invalid input!</p></small>
            {/if}
          {#if !formSubmitted}
            <Button type="submit">Log in</Button>
          {:else}
            <Button disabled>
              <Reload class="mr-2 h-4 w-4 animate-spin" />
              Please wait
            </Button>
          {/if}
        </div>
      </form>
    </div>
  </div>
</div>
