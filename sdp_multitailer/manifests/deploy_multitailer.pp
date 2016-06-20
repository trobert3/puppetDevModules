class deploy_multitailer ($rabbitmq_host,
                          $rabbitmq_port,
                          $rabbitmq_user,
                          $rabbitmq_password,
                          $rabbitmq_publisherConfirms,
                          $routing_key_expression,
                          $functional_user,
                          $multitailer_package,
                          $instalation_location
                          ) {

    # $rabbitmq_host = "RTIDEV-5292164895.eu-de1.plex.vodafone.com"
    # $rabbitmq_port = "8089"
    # $rabbitmq_user = "vfexternal"
    # $rabbitmq_password = "vfexternal"
    # $rabbitmq_publisherConfirms = false
    # $routing_key_expression = "(headers.containsKey('log_SOURCE') ? headers.log_SOURCE : '--')"

    include vodafone_java

	file { ['/var/SP/log/', '/var/SP/run/', '/var/SP/log/multitailer/', '/var/SP/run/multitailer/']:
		ensure	=> "directory",
		owner => "$functional_user",
		group => "$functional_user",
		mode => 0755,
	}

    $version = match($multitailer_package, '(?:(\d+)\.){0,5}(\*|\d+)')[0]
    $gz_path = "/tmp/${multitailer_package}"

    file { $gz_path:
        ensure => file,
        source => "puppet:///archives/${multitailer_package}",
    }
  
    archive { $gz_path:
        path         => $gz_path,
        # cleanup     => true, # Do not use this argument with this workaround
        extract      => true,
        extract_path => $instalation_location,
        creates      => "${instalation_location}/multitailer-${version}", #directory inside tgz
        require      => [ File[$gz_path] ],
    }

	file { '${instalation_location}/multitailerService.sh' :
		require	=> File['/opt/SP/apps/multitailer/'],
		source  => "puppet:///testing/multitailerService.sh",
		ensure  => "present",
		owner => "$functional_user",
		group => "$functional_user",
		mode => 0755,
	}

    #TODO: get from module files
	concat { '/opt/SP/apps/multitailer/conf/multitailer-config.xml' :
		require	=> File['/opt/SP/apps/multitailer/'],
		ensure  => "present",
		owner => "$functional_user",
		group => "$functional_user",
		mode => 0755,
		ensure_newline	=> true,
	}

    #TODO: parameters for rabbitMQ section. does it work with this form?
	concat::fragment { 'first_section':
		target	=> '/opt/SP/apps/multitailer/conf/multitailer-config.xml',
		content => template('multitailer/multitailer-config.xml.erb'),
		order	=> 00,
	}

    #TODO: fix. make it work
    # each($multitailerConfigBean) |String $value| {
    #     notice($value)
    #     #addMultitailerConfigBean { '$bean_name':
    #     #      $bean_class    =>  $item[bean_class],
    #     #      $logSource    =>  $item[logSource],
    #     #      $fileToTail   =>  $item[fileToTail],
    #     #      $fileRegexParserPattern =>  $item[fileRegexParserPattern],
    #     #      $fileRegexParserHostGroup =>  $item[fileRegexParserHostGroup],
    #     #      $fileRegexParserDateGroup =>  $item[fileRegexParserDateGroup],
    #     #      $fileRegexParserMessageGroup =>  $item[fileRegexParserMessageGroup],
    #     #      $fileRegexParserSeverityGroup =>  $item[fileRegexParserSeverityGroup],
    #     #      $fileRegexParserTagGroup =>  $item[fileRegexParserTagGroup],
    #     #      $fileRegexParserFacilityGroup =>  $item[fileRegexParserFacilityGroup],
    #     #      $fileDateParserParseTimezone =>  $item[fileDateParserParseTimezone],
    #     #      $fileDateParserOutputTimezone =>  $item[fileDateParserOutputTimezone],
    #     #      $fileDateParserParseFormat =>  $item[fileDateParserParseFormat],
    #     #}
    # }

	concat::fragment { 'end_section':
		target	=> '/opt/SP/apps/multitailer/conf/multitailer-config.xml',
		content	=> '</beans>',
		order	=> 99,
	}
}

