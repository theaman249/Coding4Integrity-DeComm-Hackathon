<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label/index.js";
  import { Button } from "$lib/components/ui/button";
  import BG from "$lib/images/shubham-dhage-HyxJ0yqa_8Q-unsplash.jpg";
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
  import * as Alert from "$lib/components/ui/alert";

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

  function login(email: string, pass: string) {
    $Email = email;
    $Password = pass;
    $registerStore = false;
    $loggedIn = true;
  }

  let formSubmitted = false;

  const newContactSchema = z.object({
    Email: z.string().min(5).max(45),
    Password: z.string().min(8).max(25),
  });

  const { form, errors, enhance, constraints, capture, restore } = superForm(
    defaults(zod(newContactSchema)),
    {
      SPA: true,
      validators: zod(newContactSchema),
      onSubmit()  {
        console.log('Jericho');
        formSubmitted = true;

      },
      async onUpdate({ form }) {
        if (form.valid) {
          let res = await actorBackend.loginUser(form.data.Email, form.data.Password);
          console.log(JSON.parse(res));
          $Email = form.data.Email;
          $loginStore = false;
          $loggedIn = true;
          $isValidUser = true;
          formSubmitted = false;
          goto("/");
        }
        else{
          console.log('Unable to validate form');
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
            <Label for="Password">Password</Label>
            <Input
              type="password"
              id="Password"
              name="Password"
              bind:value={$form.Password}
              on:input={checkRegex}
              {...$constraints.Password}
            />
            {#if $errors.Password}
              <small class="text-red-700 mb-2">{$errors.Password}</small>
            {/if}
          {#if !formSubmitted}
            <Button type="submit">Log in</Button>
          {:else}
            <Alert.Root>
              <Alert.Title>Heads up!</Alert.Title>
              <Alert.Description>
                Please doubble check your password.
              </Alert.Description>
            </Alert.Root>
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
