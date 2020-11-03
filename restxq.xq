module namespace voice = 'http://www.univie.ac.at/voice/ns/1.0';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $voice:collection := 'VOICEmerged';
declare variable $voice:corpusHeader as document-node() := doc('VOICEheader/_corpus-header.xml_');

declare
  %rest:path("VOICE_CLARIAH/corpusTree")
  %rest:GET
  %rest:produces("application/json")
  %rest:produces("application/xml")
  %rest:produces("text/html")
  %rest:query-param("method", "{$method}", "json")
function voice:get-tree-as-xml($method as xs:string) {
    let $ret := <json type="object">
		<label>VOICE</label>
		<domains type="array">{
			for $t in collection($voice:collection)//tei:TEI
	        let $id := $t/@xml:id
	        let $dom := substring($id, 1, 2)
       		group by $dom 
        	return 
        	<_ type="object">
		    	<label>{$dom}</label>
				<speechEvents type="array">{
	    	        for $i in $id
		            let $header := root($i)//tei:teiHeader 
		            let $title := $header//tei:titleStmt/tei:title
		           
		            let $speakers_no := $header//tei:personGrp[@role = 'speakers']/xs:integer(@size)
		            let $speakers_bucket := 
		                  switch (true())
		                      case $speakers_no le 3 return "2–3"
		                      case $speakers_no ge 4 and $speakers_no le 6 return "4–6"
		                      case $speakers_no ge 7 and $speakers_no le 10 return "7–10"
		                      case $speakers_no ge 11 and $speakers_no le 14 return "11–14"
		                      default return "15 and more"
		                      
		            let $interactants_no := $header//tei:personGrp[@role = 'interactants']/xs:integer(@size)
		            
		            let $interactants_bucket :=
		                  switch (true())
		                      case $interactants_no le 3 return "2–3"
		                      case $interactants_no ge 4 and $interactants_no le 6 return "4–6"
		                      case $interactants_no ge 7 and $interactants_no le 10 return "7–10"
		                      case $interactants_no ge 11 and $interactants_no le 14 return "11–14"
		                      default return "15 and more"
		            
		            (: CHANGEME: This should be inside of extent :)
		            let $no_of_words := $header//tei:note[starts-with(.,'Words')]/xs:integer(normalize-space(substring-after(.,'Words:')))
		            let $dur := $header//tei:recording/xs:duration(@dur),
		                $dur_in_seconds := seconds-from-duration($dur)+minutes-from-duration($dur)*60+hours-from-duration($dur)*1200
		            let $order := replace($i, '\p{L}','')
		            let $speech_event_type := substring-before(substring-after($i, $dom),$order)
		            
		            
		            order by $speech_event_type, xs:integer($order) ascending
		            (:where $interactants_no ne 0:)
	    	        return
						<_ type="object">
							<id>{data($i)}</id>
							<title>{normalize-space($title)}</title>
							<words type="number">{$no_of_words}</words>
							<duration type="number">{$dur_in_seconds}</duration>
							<speakers type="number">{$speakers_no}</speakers>
							<speakersBucket>{$speakers_bucket}</speakersBucket>
							<interactants type="number">{$interactants_no}</interactants>
							<interactantsBucket>{$interactants_bucket}</interactantsBucket>
						</_>
				}</speechEvents>
        	</_>
	    }</domains>
   </json>
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("VOICE_CLARIAH/corpus")
  %rest:GET
  %rest:produces("application/xml")
  %rest:produces("application/json")
  %rest:query-param("method", "{$method}", "json")
function voice:getHeader($method as xs:string) {
    let $ret := switch($method)
      case 'json' return json:serialize($voice:corpusHeader)
      default return $voice:corpusHeader   
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("VOICE_CLARIAH/speechEvent/{$id}")
  %rest:GET
  %output:method("xml")
function voice:get-doc($id) {
    doc($voice:collection||"/"||$id||".xml")
};

declare
  %rest:path("VOICE_CLARIAH/speechEvent/{$id}/header")
  %rest:GET
  %output:method("xml")
function voice:get-header($id) {
    doc($voice:collection||"/"||$id||".xml")//tei:teiHeader
};
