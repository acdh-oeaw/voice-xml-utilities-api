module namespace voice = 'http://www.univie.ac.at/voice/ns/1.0';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare
  %rest:path("VOICE_CLARIAH/corpusTree")
  %rest:GET
  %rest:produces("application/xml")
  %rest:produces("text/html")
  %output:method("xml")
  
function voice:get-tree-as-xml() {
    <json type="object">
		<label>VOICE</label>
		<domains type="array">{
			for $t in collection('VOICEmerged')//tei:TEI
	        let $id := $t/@xml:id
       		group by $dom := substring($id, 1, 2)
        	return 
        	<_ type="object">
		    	<label>{$dom}</label>
				<speechEvents type="array">{
	    	        for $i in $id
		            let $title := root($i)//tei:titleStmt/tei:title
	    	        return
						<_ type="object">
							<id>{data($i)}</id>
							<title>{data($title)}</title>
						</_>
				}</speechEvents>
        	</_>
	    }</domains>
   </json>
};

declare
  %rest:path("VOICE_CLARIAH/corpusTree")
  %rest:GET
  %rest:produces("application/json")
  %output:method("json")
  
function voice:get-tree-as-json() {
	voice:get-tree-as-xml()
};

declare
  %rest:path("VOICE_CLARIAH/corpus")
  %rest:GET
  %rest:produces("application/xml")
  %output:method("xml")
function voice:getHeader-as-xml() {
    doc('VOICEheader/_corpus-header.xml_')
};

declare
  %rest:path("VOICE_CLARIAH/corpus")
  %rest:GET
  %rest:produces("application/json")
  %output:method("json")
function voice:getHeader-as-json() {
    json:serialize(doc('VOICEheader/_corpus-header.xml_'))
};

declare
  %rest:path("VOICE_CLARIAH/speechEvent/{$id}")
  %rest:GET
  %output:method("xml")
function voice:get-doc($id) {
    doc('VOICEmerged/'||$id||".xml")
};

declare
  %rest:path("VOICE_CLARIAH/speechEvent/{$id}/header")
  %rest:GET
  %output:method("xml")
function voice:get-header($id) {
    doc('VOICEmerged/'||$id||".xml")//tei:teiHeader
};
