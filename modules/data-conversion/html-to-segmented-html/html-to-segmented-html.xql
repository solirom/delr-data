xquery version "3.1";

declare namespace html = "http://www.w3.org/1999/xhtml";

let $paragraphs := doc("/db/CL-CU.html")//html:p
let $delimiter-indexes :=
    for $paragraph at $i in $paragraphs
    
    return
        if ($paragraph = ("&#160;", ""))
        then $i
        else ()
let $delimiter-indexes-number := count($delimiter-indexes)
let $delimiter-indexes := (0, $delimiter-indexes)
let $subsequence-limits := array {
    for $delimiter-index in (1 to $delimiter-indexes-number)
    let $start := $delimiter-indexes[$delimiter-index] + 1
    let $length := $delimiter-indexes[$delimiter-index + 1] - $start
    
    return array {($start, $length)}
}

return
    for $subsequence-limit in $subsequence-limits?*
    let $html-entry := subsequence($paragraphs, $subsequence-limit?1, $subsequence-limit?2)
    let $headword-string := analyze-string(substring-before($html-entry[1]/string(), " "), "\d*")
    let $headword := string-join($headword-string/fn:non-match[. != ''])
    let $homonym-number := $headword-string/fn:match[. != '']
    let $uuid := "uuid-" || util:uuid($headword)
    
    let $tei-entry :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="uuid-{$uuid}" version="3.3.0" source="0.1">
        	<teiHeader>
        		<fileDesc>
        			<titleStmt>
        				<title />
        				<author />
        				<editor role="reviewer" />
        			</titleStmt>
        			<publicationStmt>
        				<publisher>Romanian Academy, Philology and Literature Section</publisher>
        			</publicationStmt>
        			<sourceDesc>
        				<p>born digital</p>
        			</sourceDesc>
        		</fileDesc>
        		<profileDesc>
        			<creation>
        				<date when-iso="{current-dateTime()}" />
        			</creation>
        		</profileDesc>
        		<revisionDesc />
        	</teiHeader>
        	<text>
        		<body>
        			<entry>
        				<form type="headword">
        					<orth n="{$homonym-number}">{$headword}</orth>
        				</form>
        			</entry>
        			<entryFree>{$html-entry}</entryFree>
        		</body>
        	</text>
        </TEI>

    return xmldb:store("/db/data/delr", $uuid || ".xml", $tei-entry)