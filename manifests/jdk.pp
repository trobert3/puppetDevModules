class java::jdk ($instalationLocation='/opt/SP/apps/', $functionalUser='jboss', $version=7) {

    $jdkPackage = 'jdk1.7.0_55'
    if $version == 6 {
        $jdkPackage = 'jdk1.6.0_37'
    } elsif $version == 8 {
        $jdkPackage = 'jdk1.8.0_25'
    }

    $osType = 'linux'
    if $::osfamily=='Solaris' {
        $osType = 'solaris'
    }

    file { "${instalationLocation}" :
        ensure  => "directory",
        owner => "$functionalUser",
        group => "$functionalUser",
        mode => "0755",
    }

    file { "${instalationLocation}/${jdkPackage}" :
        source  => "puppet:///${jdkPackage}-${osType}-${::architecture}",
        ignore  => ['.git', '.svn'],
        links => follow,
        ensure  => "directory",
        recurse => true,
        owner => "$functionalUser",
        group => "$functionalUser",
        mode => "0755",
    }
}
