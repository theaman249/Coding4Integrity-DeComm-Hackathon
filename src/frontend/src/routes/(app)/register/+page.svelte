<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label/index.js";
  import { Button } from "$lib/components/ui/button";
  import BG from "$lib/images/shubham-dhage-HyxJ0yqa_8Q-unsplash.jpg";
  import {
    loggedIn,
    registerStore,
    fullName,
    loginStore,
    isValidUser,
    Email,
    password,
    passwordConfirm,
    walletID,
  } from "$lib/data/stores/stores.js";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import Reload from "svelte-radix/Reload.svelte";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";
    import { toast } from "svelte-sonner";

  let formSubmitted = false;


  const newContactSchema = z.object({
    fullName: z.string().min(2).max(25),
    email: z.string().min(5).max(45),
    password: z.string().min(8).max(25),
    passwordConfirm: z.string().min(8).max(25),
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
          let res = await actorBackend.createUser(form.data.fullName, form.data.email, form.data.password);
          // console.log(res); 
          if (res.message == "user created successfully")
          {
            $fullName = form.data.fullName;
            $Email = form.data.email;
            $walletID = res.walletID;
            goto("/");

            
          }
          else{
            toast.error(res.message);
          }

          $passwordConfirm = form.data.passwordConfirm;
          $registerStore = false;
          $loggedIn = true;
          $isValidUser = true;
          formSubmitted = false;
          
        }
      },
    },
  );

  function loginCheck() {
    $loginStore = true;
    $registerStore = false;
    goto("/login");
  }

  onMount(async ()=>{
    try{
      // let res = await actorBackend.toJson("21","JSonc","json@123");

      // console.log(JSON.parse(res));
          
      //console.log(res);
    } catch (err:unknown){
      console.log(err);
    }

  });

  export const snapshot = { capture, restore };
</script>

<svelte:head>
  <title>Register - DeComm</title>
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
      <Button variant="outline" on:click={loginCheck}>Login</Button>
    </div>
    <div class="block text-center">
      <h1 class="font-semibold text-2xl mb-2">Create an account</h1>
      <p class="opacity-75">Enter your details below to register your account</p>
      <form method="POST" use:enhance>
        <div class="grid w-full max-w-sm items-center gap-1.5 text-start mt-5">
          <Label for="fullName">Full name</Label>
          <Input
            type="text"
            id="fullName"
            name="fullName"
            bind:value={$form.fullName}
            {...$constraints.fullName}
          />{#if $errors.fullName}
          <small class="text-red-700 mb-2">{$errors.fullName}</small>
        {/if}
          <Label for="email">Email</Label>
          <Input
            type="email"
            id="email"
            name="email"
            bind:value={$form.email}
            {...$constraints.email}
          />{#if $errors.email}
          <small class="text-red-700 mb-2">{$errors.email}</small>
        {/if}
          <Label for="password">Password</Label>
          <Input
            type="password"
            id="password"
            name="password"
            bind:value={$form.password}
            {...$constraints.password}
          />{#if $errors.password}
          <small class="text-red-700 mb-2">{$errors.password}</small>
        {/if} 
        <Label for="passwordConfirm">Confirm Password</Label>
        <Input
          type="password"
          id="passwordConfirm"
          name="passwordConfirm"
          bind:value={$form.passwordConfirm}
          {...$constraints.passwordConfirm}
          />
          {#if $errors.passwordConfirm}
            <small class="text-red-700 mb-2">{$errors.passwordConfirm}</small>
        {/if}
          {#if !formSubmitted}
            <Button type="submit">Register</Button>
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
