<?php

return array(
    'mysql.host' => 'localhost',
    'mysql.user' => 'root',
    'mysql.pass' => '',

    'phabricator.base-uri' => 'http://phabricator.dev/',

    'storage.upload-size-limit' => '2M',

    'syntax.filemap' => array(
      '@\\.arcconfig$@' => 'js',
      '@\\.divinerconfig$@' => 'js',

      '@\\.module$@' => 'php',
      '@\\.theme$@' => 'php',
      '@\\.install$@' => 'php',
      '@\\.profile$@' => 'php',
    ),
);
