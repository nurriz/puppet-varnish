class varnish::repo(
  $ensure  = 'present',
  $source  = $::osfamily ? {
    'Debian' => 'varnish-cache',
    'RedHat' => 'varnish-cache',
  },
) {
  if defined(Class['varnish::install']) {
    Class['varnish::repo'] -> Class['varnish::install']
  }

  case $::osfamily {
    'Debian': {
      case $source {
        'distro': {
        }
        'varnish-cache': {
          include ::apt
          apt::key { '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E':
            source => 'https://packagecloud.io/varnishcache/varnish41/gpgkey',
          }
          $os_downcase = downcase($::operatingsystem)
          apt::source { 'varnish':
            ensure   => $ensure,
            location => "https://packagecloud.io/varnishcache/varnish41/${os_downcase}/",
            release  => $::lsbdistcodename,
            repos    => 'main',
            key      => '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E',
          }
        }
        default: {
          fail 'Repository source must be one of "distro" or "varnish-cache"'
        }
      }
    }
    'Redhat': {
      yumrepo {'epel':
        descr    => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \$basearch",
        baseurl  => "http://download.fedoraproject.org/pub/epel/${::operatingsystemmajrelease}/\$basearch",
        enabled  => 1,
        gpgkey   => "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
        gpgcheck => 0,
      }
      case $source {
        'epel': {
        }
        'varnish-cache': {
          yumrepo { 'varnish':
            ensure   => $ensure,
            descr    => 'varnish',
            baseurl  => "https://packagecloud.io/varnishcache/varnish41/el/${::operatingsystemmajrelease}/\$basearch",
            enabled  => '1',
            gpgcheck => '0',
            gpgkey   => 'https://packagecloud.io/varnishcache/varnish41/gpgkey',
          }
        }
        default: {
          fail 'Repository source must be one of "epel" or "varnish-cache"'
        }
      }
    }
    default: {
      fail "Unsupported Operating System family: ${::osfamily}"
    }
  }
}
