define sdp_multitailer::add_config_bean($bean_name=$title, 
                                        $config_file,
                                        $bean_class,
                                        $logSource,
                                        $fileToTail,
                                        $fileRegexParserPattern = "(.*)",
                                        $fileRegexParserHostGroup = "0",
                                        $fileRegexParserDateGroup = "0",
                                        $fileRegexParserMessageGroup = "1",
                                        $fileRegexParserSeverityGroup = "0",
                                        $fileRegexParserTagGroup = "0",
                                        $fileRegexParserFacilityGroup = "0",
                                        $fileDateParserParseTimezone = "UTC",
                                        $fileDateParserOutputTimezone = "UTC",
                                        $fileDateParserParseFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                       ) {
    # TODO: improve validation

    concat::fragment { $bean_name:
        target  => $config_file,
        content => template('multitailer/config-bean.xml.erb'),
        order   => 10,
    }
}

