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
       		group by $dom := substring($id, 1, 2)
        	return 
        	<_ type="object">
		    	<label>{$dom}</label>
				<speechEvents type="array">{
	    	        for $i in $id
		            let $title := root($i)//tei:titleStmt/tei:title
		            order by $i
	    	        return
						<_ type="object">
							<id>{data($i)}</id>
							<title>{data($title)}</title>
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
