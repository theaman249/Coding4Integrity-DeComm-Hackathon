import { persisted } from 'svelte-persisted-store';

// Create persisted stores
export const loggedIn = persisted('loggedIn', {
  value: false,
});

export const accountType = persisted('accountType', {
  value: 'Personal',
});

export const registerStore = persisted('registerStore', {
  value: true,
});

export const loginStore = persisted('loginStore', {
  value: false,
});

export const fullName = persisted('fullName', {
  value: '',
});

export const cart = persisted('cart', {
  value: 0,
});

export const cartPage = persisted('cartPage', {
  value: false,
});

export const cartProducts = persisted('cartProducts', []);

export const addToCart = (product) => {
  cartProducts.update((products) => [...products, product]);
};

export const removeFromCart = (productID) => {
  cartProducts.update((products) => products.filter((p) => p.productID !== productID));
};

export const clearCart = () => {
  cartProducts.set([]);
};
