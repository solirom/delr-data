xquery version "3.1";

import module namespace config = "http://solirom.ro/ns/delr-data-app/configuration/" at "modules/configuration/configuration.xqm";

declare variable $home external;
declare variable $target external;
declare variable $dir external;

declare variable $system-config-collection-path := "/system/config/db";

declare function local:create-collections-recursively($target-collection-uri as xs:string, $new-collection-path-steps as xs:string*) as xs:string* {
    if (exists($new-collection-path-steps))
    then
	let $new-collection-name := $new-collection-path-steps[1]
	let $new-collection-uri := $target-collection-uri || "/" || $new-collection-name
	
	return (
            if (not(xmldb:collection-available($new-collection-uri)))
            then xmldb:create-collection($target-collection-uri, $new-collection-name)
            else ()
            ,
            local:create-collections-recursively($new-collection-uri, subsequence($new-collection-path-steps, 2))
    )
    else ()
};

declare function local:add-index-configuration-file($collection-path as xs:string) {
	let $index-collection-path := $system-config-collection-path || $collection-path
	
	return (
		if (not(xmldb:collection-available($index-collection-path)))
		then local:create-collections-recursively($system-config-collection-path, tokenize($collection-path, "/"))
		else ()
		,	
		xmldb:store-files-from-pattern($index-collection-path, $dir, "modules/indexes" || $collection-path || "/*.xconf")
		,
		xmldb:reindex($collection-path)
	)
};

local:add-index-configuration-file($config:data-dir)
