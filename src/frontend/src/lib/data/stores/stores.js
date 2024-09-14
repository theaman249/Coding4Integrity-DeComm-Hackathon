import { persisted } from "svelte-persisted-store";

export const loggedIn = persisted("loggedIn", {
  value: false,
});

export const isValidUser = persisted("isValidUser", {
  value: false,
});

export const accountType = persisted("accountType", {
  value: "Personal Account",
});

export const registerStore = persisted("registerStore", {
  value: true,
});

export const loginStore = persisted("loginStore", {
  value: false,
});

export const Email = persisted("Email", {
  value: "",
});

export const Password = persisted("Password", {
  value: "",
});

export const cart = persisted("cart", {
  value: 0,
});

export const cartPage = persisted("cartPage", {
  value: false,
});
