include '::archive'

class vodafone_java::jdk (
    $instalationLocation,
    $functionalUser,
    $version
    ) {

    validate_absolute_path($instalationLocation)
    validate_string($functionalUser)
    validate_numeric($version)

    #TODO: Add option to deploy specific tar. This model works because we know
    #      what we have ready to deploy and we know where we want it but it
    #      lacks flexibility

    $osType = 'linux'
    if $::osfamily=='Solaris' {
        $osType = 'solaris'
    }

    $arch = 'x64'
    if $::architecture=='i86pc' {
        $arch = 'i386'
    }

    $versionPrefix = 'jdk1.7.0_67'
    if $version == 6 {
        $versionPrefix = 'jdk1.6.0_41'
    } elsif $version == 8 {
        $versionPrefix = 'jdk1.8.0_40'
    }

    $jdkPackage = "${versionPrefix}-${osType}-${arch}.tar.gz"

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
