module.exports = {
  // Define branches for releases: 'release/**' for regular releases, 'beta/**' for pre-releases
  branches: ['release/**', { name: 'beta/**', prerelease: true }],

  // Plugins for the release process
  plugins: [
    // Plugin to analyze commit messages and determine the type of release (major, minor, patch)
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits', // Use Conventional Commits preset
        releaseRules: [
          { type: "fix", release: "patch" },         // Fixes trigger a patch release
          { type: "feat", release: "minor" },        // New features trigger a minor release
          { type: "refactor", release: "patch" },    // Refactoring triggers a patch release
          { type: "perf", release: "patch" },        // Performance improvements trigger a patch release
          { type: "test", release: false },          // Test changes don't trigger a release
          { type: "database", release: "minor" },    // Database changes trigger a minor release
          { type: "breaking", release: "major" },    // Breaking changes trigger a major release
          { type: "security", release: "patch" },    // Security fixes trigger a patch release
          { type: "removed", release: "patch" },     // Removed features trigger a patch release
          { type: "ci", release: false },            // CI changes don't trigger a release
          { type: "chore", release: false },         // Chores don't trigger a release
          { type: "style", release: "patch" }        // Style changes trigger a patch release
        ],
      },
    ],

    // Plugin to generate release notes based on commit messages
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        presetConfig: {
          types: [
            { type: "fix", section: ":hammer: Bug Fix :hammer:" },                // Section for fixes
            { type: "feat", section: ":stars: New Feature :stars:" },             // Section for new features
            { type: "refactor", section: ":persevere: Code Refactor :persevere:" },// Section for refactors
            { type: "perf", section: ":dash: Performance Boost :dash:" },         // Section for performance improvements
            { type: "test", section: ":link: Test Implemented :link:" },          // Section for test changes
            { type: "breaking", section: ":boom: BREAKING CHANGE :boom:" },       // Section for breaking changes
            { type: "database", section: ":scroll: Database Change :scroll:" },   // Section for database changes
            { type: "security", section: ":key: Security Improvements :key:" },   // Section for security improvements
            { type: "removed", section: ":x: Removed :x:" },                      // Section for removed features
            { type: "ci", section: ":curly_loop: Continuous Integration :curly_loop:" }, // Section for CI changes
            { type: "chore", section: ":curly_loop: What a drag! :curly_loop:" },  // Section for chore updates
            { type: "style", section: ":dress: UI! :dress:" }                      // Section for style changes
          ],
        },
      },
    ],

    // Plugin to generate and update the changelog file
    '@semantic-release/changelog',

    // Plugin to update npm package versions but skip publishing to npm registry
    [
      '@semantic-release/npm',
      {
        npmPublish: false, // Skip npm publish
      },
    ],

    // Plugin to execute custom shell commands during the release process
    [
      '@semantic-release/exec',
      {
        // Prepare step: bump version, build the client, and return to the root directory
        prepareCmd: 'VERSION=${nextRelease.version} npm run bump && cd client && npm run build && cd ../',
      },
    ],

    // Plugin to commit release-related files (e.g., changelog, package.json) to the Git repository
    [
      '@semantic-release/git',
      {
        assets: [
          'CHANGELOG.md',            // Commit changelog updates
          'package.json',            // Commit root package.json changes
          'package-lock.json',       // Commit root package-lock.json changes
          'server/package.json',     // Commit server package.json changes
          'server/package-lock.json',// Commit server package-lock.json changes
          'client/package.json',     // Commit client package.json changes
          'client/package-lock.json',// Commit client package-lock.json changes
          'server/assets/**/*'       // Commit server asset changes
        ],
      },
    ],

    // Plugin to create a release on GitHub and upload assets
    [
      '@semantic-release/github',
      {
        assets: [
          { path: "server", label: "Server Distribution" } // Label for the server distribution files
        ]
      }
    ]
  ],
};
