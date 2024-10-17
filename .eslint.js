module.exports = {
  // Set this configuration as the root (no further configurations will be inherited)
  root: true,
  
  // Define the environment settings
  env: {
    browser: true,  // Enable browser global variables (e.g., window, document)
    node: true,     // Enable Node.js global variables and Node.js-specific rules
    es2021: true,   // Enable ES2021 syntax support
    es6: true       // Enable ES6 features (let, const, arrow functions, etc.)
  },

  // Use Prettier's recommended rules to ensure code formatting
  extends: ["plugin:prettier/recommended"],

  // Include Prettier as a plugin to apply formatting rules
  plugins: ["prettier"],

  // Use Babel as the parser for ESLint
  parser: "@babel/eslint-parser",

  // Parser options for ECMAScript modules and the latest ECMAScript version
  parserOptions: {
    ecmaVersion: "latest",      // Support the latest ECMAScript features
    sourceType: "module"        // Use ES6 modules (import/export syntax)
  },

  // Custom ESLint rules
  rules: {
    // Enforce Prettier formatting as an ESLint error
    "prettier/prettier": "error",

    // Enforce a maximum line length of 300 characters, ignoring comments and URLs
    "max-len": [
      "error",
      {
        code: 300,             // Maximum number of characters in a line
        ignoreComments: true,  // Ignore comments when checking line length
        ignoreUrls: true       // Ignore URLs when checking line length
      }
    ],

    // Disable the requirement for `require()` to be at the top level
    "global-require": "off",

    // Enforce double quotes for strings
    quotes: ["error", "double"],

    // Allow console statements in development but show warnings in production
    "no-console": process.env.NODE_ENV === "production" ? "warn" : "off",

    // Allow debugger statements in development but show warnings in production
    "no-debugger": process.env.NODE_ENV === "production" ? "warn" : "off"
  }
};
