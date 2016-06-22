class sdp_multitailer::configure($rabbitmq_host,
                                 $rabbitmq_port,
                                 $rabbitmq_user,
                                 $rabbitmq_password,
                                 $rabbitmq_publisherConfirms,
                                 $routing_key_expression,
                                 $functional_user,
                                 $instalation_location,
                                ) {
    $config_file = '${instalation_location}/conf/multitailer-config.xml'

    # TODO: check path using stdlib
    concat { $config_file :
        ensure  => "present",
        owner => $functional_user,
        group => $functional_user,
        mode => 0755,
        ensure_newline  => true,
    }

    concat::fragment { 'first_section':
        target  => $config_file,
        content => template('sdp_multitailer/multitailer-config.xml.erb'),
        order   => 00,
    }

    each($config_beans) |String $value| {
        notice($value)
        sdp_multitailer::add_config_bean{ '$bean_name':
            $bean_class    =>  $item[bean_class],
            $logSource    =>  $item[logSource],
            $fileToTail   =>  $item[fileToTail],
            $fileRegexParserPattern =>  $item[fileRegexParserPattern],
            $fileRegexParserHostGroup =>  $item[fileRegexParserHostGroup],
            $fileRegexParserDateGroup =>  $item[fileRegexParserDateGroup],
            $fileRegexParserMessageGroup =>  $item[fileRegexParserMessageGroup],
            $fileRegexParserSeverityGroup =>  $item[fileRegexParserSeverityGroup],
            $fileRegexParserTagGroup =>  $item[fileRegexParserTagGroup],
            $fileRegexParserFacilityGroup =>  $item[fileRegexParserFacilityGroup],
            $fileDateParserParseTimezone =>  $item[fileDateParserParseTimezone],
            $fileDateParserOutputTimezone =>  $item[fileDateParserOutputTimezone],
            $fileDateParserParseFormat =>  $item[fileDateParserParseFormat],
        }
    }

    concat::fragment { 'end_section':
        target  => $config_file,
        content => '</beans>',
        order   => 99,
    }

}
