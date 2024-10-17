module.exports = {
  // Use the conventional commit rules from the '@commitlint/config-conventional' package
  extends: ['@commitlint/config-conventional'],
  
  // Custom commitlint rules
  rules: {
    // Enforce allowed commit types (e.g., fix, feat, refactor, etc.)
    'type-enum': [
      2, // 2 = error level
      'always', // Always enforce this rule
      [
        'fix',       // Bug fixes
        'feat',      // New features
        'refactor',  // Code refactoring without adding new features or fixing bugs
        'perf',      // Performance improvements
        'test',      // Adding or updating tests
        'database',  // Database changes
        'breaking',  // Breaking changes
        'security',  // Security improvements
        'removed',   // Features removed
        'ci',        // Changes to CI configuration
        'chore',     // Non-production code changes (e.g., updating build tasks)
        'style'      // Code style changes (e.g., formatting, whitespace)
      ],
    ],
    
    // Disable footer max line length enforcement
    'footer-max-line-length': [0, 'always'],
    
    // Disable body max line length enforcement
    'body-max-line-length': [0, 'always'],
  },
};
