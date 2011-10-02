node default {
  exec { '/usr/bin/apt-get update': }

  group { 'puppet': ensure => present }

  package {
    'imagemagick': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'curl': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'openjdk-6-jre': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'build-essential': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'libssl-dev': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'libreadline5-dev': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'zlib1g-dev': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
    'libsqlite3-dev': ensure => installed,
      require => Exec['/usr/bin/apt-get update'];
  }

  exec { 'download apollo':
    command => "/usr/bin/curl -O http://apache.mirrors.timporter.net/activemq/activemq-apollo/1.0-beta5/apache-apollo-1.0-beta5-unix-distro.tar.gz",
    cwd => "/tmp",
    creates => "/tmp/apache-apollo-1.0-beta5-unix-distro.tar.gz",
    require => Package['curl']
  }

  exec { 'unpack apollo':
    require => Exec['download apollo'],
    creates => "/tmp/apache-apollo-1.0-beta5",
    cwd => "/tmp",
    command => "/bin/tar -xzf ./apache-apollo-1.0-beta5-unix-distro.tar.gz"
  }

  exec { 'create broker':
    require => [ Exec['unpack apollo'], Package['openjdk-6-jre'] ],
    creates => '/tmp/broker',
    cwd => "/tmp/apache-apollo-1.0-beta5",
    command => "/tmp/apache-apollo-1.0-beta5/bin/apollo create /tmp/broker"
  }

  file { '/etc/init.d/broker':
    ensure => link,
    target => '/tmp/broker/bin/apollo-broker-service',
    require => Exec['create broker']
  }

  file { '/tmp/broker/etc/apollo.xml':
    source => '/tmp/vagrant-puppet/manifests/apollo.xml',
    ensure => present,
    require => Exec['create broker']
  }

  service { 'broker':
    provider => base,
    ensure => running,
    start => '/etc/init.d/broker start && sleep 5',
    pattern => 'apollo',
    require => [ File['/etc/init.d/broker'], File['/tmp/broker/etc/apollo.xml'] ]
  }

  exec { 'download Ruby':
    command => "/usr/bin/curl -O ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz",
    creates => "/tmp/ruby-1.9.2-p290.tar.gz",
    cwd => "/tmp",
    require => Package["curl"]
  }

  exec { 'unpack Ruby':
    command => "/bin/tar -xzf ./ruby-1.9.2-p290.tar.gz",
    creates => "/tmp/ruby-1.9.2-p290",
    cwd => "/tmp",
    require => Exec['download Ruby']
  }

  exec { 'install Ruby':
    command => "/tmp/ruby-1.9.2-p290/configure --prefix=/usr && make && make install",
    cwd => "/tmp/ruby-1.9.2-p290",
    refreshonly => true,
    subscribe => Exec['unpack Ruby'],
    path => [ ".", "/usr/bin", "/bin" ]
  }

  package { 'bundler':
    provider => gem,
    ensure => installed,
    require => Exec['install Ruby']
  }

  exec { 'bundle gems':
    cwd => '/usr/local/src/constable',
    command => '/usr/bin/bundle',
    require => Package['bundler']
  }

  service { 'constabled':
    provider => base,
    ensure => running,
    start => 'cd /usr/local/src/constable && nohup bundle exec /usr/local/src/constable/bin/constabled >/tmp/constabled.log 2>/tmp/constabled.err &',
    require => [ Service['broker'], Exec['bundle gems'], Package['imagemagick'] ]
  }
}
