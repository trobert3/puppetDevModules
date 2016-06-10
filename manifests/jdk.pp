include '::archive'

class vodafone_java::jdk (
    $instalationLocation,
    $functionalUser,
    $version
    ) {

    validate_absolute_path($instalationLocation)
    validate_string($functionalUser)
    validate_numeric($version)

    #TODO: Add architecture

    $osType = 'linux'
    if $::osfamily=='Solaris' {
        $osType = 'solaris'
    }

    $jdkPackage = "jdk-7u55-${osType}-i586.tar.gz"
    if $version == 6 {
        $jdkPackage = ''
    } elsif $version == 8 {
        $jdkPackage = ''
    }

    $gz_path = "/tmp/${jdkPackage}"

    file { "${instalationLocation}" :
        ensure  => "directory",
        owner => "$functionalUser",
        group => "$functionalUser",
        mode => "0755",
    }

    # ugly but works for now
    file { "${gz_path}":
        ensure => file,
        source => "puppet:///archives/${jdkPackage}",
    }

    archive { $gz_path:
        path            => $gz_path,
        #cleanup         => true, # Do not use this argument with this workaround
        extract         => true,
        extract_path    => "${instalationLocation}",
        creates         => "${instalationLocation}/jdk1.${version}-${osType}", #directory inside tgz
        require         => [ File["${gz_path}"] ],
    }
}
