Package.describe({
  name: 'castorp:reactive-input',
  version: '0.0.1_7',
  summary: 'Simple two-way data binding for Meteor.',
  git: 'https://github.com/vadimrostok/reactive-input',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use([
    'templating',
    'coffeescript',
    'underscore',
    'reactive-var'
  ], 'client');
  api.versionsFrom('1.0.3.2');
  api.addFiles([
    'client/castorp:reactive-input.html',
    'client/castorp:reactive-input.coffee'
  ]);
});
