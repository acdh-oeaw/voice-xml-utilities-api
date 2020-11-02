declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace voice = 'http://www.univie.ac.at/voice/ns/1.0';

declare
  %rest:path("VOICE_CLARIAH/corpusTree")
  %rest:GET
  %output:method("xml")
  
function voice:get_tree() {
    <corpus label="VOICE">{    
        for $t in collection('VOICEmerged')//tei:TEI
        let $id := $t/@xml:id,
            $title := $t//tei:titleStmt/tei:title
        group by $dom := substring($id, 1, 2)
        return 
        <group label="{$dom}">{
            for $i in $id
            return <doc label="{$id}" title="{$title}"/>
        }</group>
    }</corpus>
};


declare
  %rest:path("VOICE_CLARIAH/speechEvents/{$id}")
  %rest:GET
  %output:method("xml")

function voice:get($id) {
    doc('VOICEmerged/'||$id||".xml")
};
