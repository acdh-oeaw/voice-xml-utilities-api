module namespace voice = 'http://www.univie.ac.at/voice/ns/1.0';

import module namespace admin = "http://basex.org/modules/admin"; (: for logging :)
import module namespace openapi="https://lab.sub.uni-goettingen.de/restxqopenapi" at "../openapi4restxq/content/openapi.xqm";

declare namespace exist = "http://exist.sourceforge.net/NS/exist"; (: for compatibility with xsl :)
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace cq = "http://www.univie.ac.at/voice/corpusquery";

declare variable $voice:log := true();
declare variable $voice:collection := 'VOICEmerged';
declare variable $voice:apiBasePath := "/VOICE_CLARIAH";
declare variable $voice:corpusHeader as document-node() := db:open('VOICEheader', 'corpusHeader.xml');
declare variable $voice:audioDesc as document-node() := fn:parse-xml(file:read-text(file:base-dir()||'/audio/voiceAudioDesc.xml'));
declare variable $voice:audioBasePath := "https://voice.acdh.oeaw.ac.at/sound";
declare variable $voice:noskeRunCgi := "https://voice-noske.acdh-dev.oeaw.ac.at/bonito/run.cgi";
declare variable $voice:speakers := json:parse(serialize(map:merge(for $i in collection($voice:collection)//tei:listPerson//*[@sameAs]
group by $sa := $i/@sameAs/data()
let $c := count($i)
order by $c descending
return map {substring($sa, 2):
map{"age": $i[1]/tei:age/text(),
    "sex": $i[1]/tei:sex/text(),
    "occupation": replace($i[1]/tei:occupation/text(), '\s+$', '')[. != ''],
    "L1": array {$i[1]/tei:langKnowledge/*[@level="L1"]/@tag/data()},
    "refs" : map:merge(
      for $r in $i/@xml:id
      return map {substring-before($r/data(), '_'): map{
        "role": $r/../@role/data(),
        "tag": substring-after($r/data(), '_')
      }}
    )}
  }
), map {"method": "json"}));

declare %private function voice:path($textid as xs:string, $view as xs:string){
    let $b :=
        if ($textid = "teiCorpus")
        then $voice:apiBasePath||"/corpus"
        else $voice:apiBasePath||"/speechEvent/"||$textid
    return switch ($view)
        case "tei"      return $b
        case "audio"    return if ($voice:audioDesc//cq:SoundFile[@corresponds=concat('#', $textid)]) then $voice:audioBasePath||"/"||$textid||".mp3" else ()
        default return $b||"/"||$view
};


declare variable $voice:speakersNoVocab := 
    <vocab name="speakersBucket">
        <entry min="2" max="3">2–3</entry>
        <entry min="4" max="6">4–6</entry>
        <entry min="7" max="10">7–10</entry>
        <entry min="11" max="14">11–14</entry>
        <entry min="15">15 and more</entry>
    </vocab>;


declare variable $voice:interactantsVocab := 
    <vocab name="interactantsBucket">
        <entry max="3">2–3</entry>
        <entry min="4" max="6">4–6</entry>
        <entry min="7" max="10">7–10</entry>
        <entry min="11" max="14">11–14</entry>
        <entry min="15">15 and more</entry>
    </vocab>;

declare variable $voice:noOfWordsVocab := 
   <vocab name="wordsBucket">
        <entry max="2999">0–2999</entry>
        <entry min="3000" max="5999">3000–5999</entry>
        <entry min="6000" max="9999">6000–9999</entry>
        <entry min="10000" max="14999">10000–14999</entry>
        <entry min="15000">15000+</entry>
    </vocab>;

declare variable $voice:durationVocab := 
   <vocab name="durationBucket">
        <entry max="1799">0–29min</entry>
        <entry min="1800" max="3599">30–59min</entry>
        <entry min="3600" max="7199">1h–1h59min</entry>
        <entry min="7200">2h+</entry>
    </vocab>;
    
declare variable $voice:speakersL1 := 
    <vocab name="speakersL1">{
        for $l in distinct-values(collection($voice:collection)//tei:langKnowledge/*[@level="L1"]/substring-before(@tag,'-'))[. != ""]
        order by $l ascending
        return <entry>{$l}</entry>
    }</vocab>;
    
declare variable $voice:relationPower := 
    <vocab name="relationPower">{
        for $p in distinct-values(collection($voice:collection)//tei:relation[@type="power"]/data(@name))[. != ""]
        order by $p ascending
        return <entry>{$p}</entry>
    }</vocab>;

declare variable $voice:relationAcquaintedness := 
    <vocab name="relationAcquaintedness">{
        for $a in distinct-values(collection($voice:collection)//tei:relation[@type="acquaintedness"]/data(@name))[. != ""]
        order by $a ascending
        return <entry>{$a}</entry>
    }</vocab>;

declare variable $voice:domains := 
    <vocab name="domain">{
        for $a in distinct-values(collection($voice:collection)//tei:TEI/substring(@xml:id,1,2))
        order by $a ascending
        return <entry>{$a}</entry>
    }</vocab>;

declare variable $voice:spets := 
    <vocab name="spet">{
        for $a in distinct-values(collection($voice:collection)//tei:TEI/replace(substring(@xml:id,3),'\d+',''))
        order by $a ascending
        return <entry>{$a}</entry>
    }</vocab>;

declare function voice:bucketByValue($vocab as element(vocab), $value as xs:integer) as xs:string{
    let $buckets := $vocab/entry
    return
        ($buckets[xs:integer(@min) le $value][xs:integer(@max) ge $value],
        $buckets[xs:integer(@min) le $value][not(@max)],
        $buckets[xs:integer(@max) ge $value][not(@min)])[1]
};      

declare function voice:vocab2array($vocab as element(vocab)){
    element {$vocab/@name} {(
        attribute {"type"} {"array"},
        for $e in $vocab/entry 
        return <_>{data($e)}</_>
    )}
};


declare
  %rest:path("/VOICE_CLARIAH/corpus/tree")
  %rest:GET
  %rest:produces("application/json")
  %rest:produces("application/xml")
  %rest:produces("text/html")
  %rest:query-param("method", "{$method}", "json")
function voice:get-tree-as-xml($method as xs:string?) {
    let $ret := (# db:copynode false #) {<json type="object">
		<label>VOICE</label>
    <title>{$voice:corpusHeader//tei:titleStmt/tei:title/text()}</title>
    <teiHeader>{serialize(xslt:transform(<cq:corpusHeader xml:space="preserve">{$voice:corpusHeader/tei:teiCorpus[1]/tei:teiHeader}</cq:corpusHeader>, 'styles/voice.xsl'), map {"method": "xhtml", "indent": "no"})}</teiHeader>
    <filterEnums type="object">{(
        voice:vocab2array($voice:speakersNoVocab),
        voice:vocab2array($voice:interactantsVocab),
        voice:vocab2array($voice:noOfWordsVocab),
        voice:vocab2array($voice:durationVocab),
        voice:vocab2array($voice:speakersL1),
        voice:vocab2array($voice:relationAcquaintedness),
        voice:vocab2array($voice:relationPower),
        voice:vocab2array($voice:domains),
        voice:vocab2array($voice:spets)
    )}</filterEnums>
    <refs type="object">
       <teiHeader>{voice:path("teiCorpus", "header")}</teiHeader>
    </refs>
    <speakers type="object">{$voice:speakers/*/*}</speakers>
		<domains type="array">{
			for $t in collection($voice:collection)//tei:TEI
	        let $id := $t/@xml:id
	        let $dom := substring($id, 1, 2)
       		group by $dom
           order by $dom ascending
        	return 
        	<_ type="object">
		    	<label>{$dom}</label>
				<speechEvents type="array">{
	    	        for $i in $id
		            let $header := root($i)//tei:teiHeader 
		            let $title := $header//tei:titleStmt/tei:title
		           
		            let $speakers_no := $header//tei:personGrp[@role = 'speakers']/xs:integer(@size)
		            let $speakers_bucket := voice:bucketByValue($voice:speakersNoVocab, $speakers_no)

		            let $interactants_no := $header//tei:personGrp[@role = 'interactants']/xs:integer(@size)
		            
		            let $interactants_bucket := voice:bucketByValue($voice:interactantsVocab, $interactants_no)

		            (: CHANGEME: This should be inside of extent :)
		            let $no_of_words := $header//tei:note[starts-with(.,'Words')]/xs:integer(normalize-space(substring-after(.,'Words:')))

                    let $no_of_words_bucket := voice:bucketByValue($voice:noOfWordsVocab, $no_of_words)
                      
		            let $dur := $header//tei:recording/xs:duration(@dur),
		                $dur_in_seconds := xs:integer(seconds-from-duration($dur)+minutes-from-duration($dur)*60+hours-from-duration($dur)*3600)

                    let $dur_bucket := voice:bucketByValue($voice:durationVocab, $dur_in_seconds)
                      

		            let $order := replace($i, '\p{L}','')
		            let $speech_event_type := substring-before(substring-after($i, $dom),$order)

		            let $audioLocation := voice:path($i, "audio")

                let $relation := $header//tei:relation

		            (: CHECKME probably there are no tracks at all :)
		            (:let $tracks := 
                        for $sf in $sfs
                        let $filename := 
                            if(count($sfs) > 1) 
                            then concat($i, "_", $sf/@num, ".mp3") 
                            else concat($i, ".mp3")
                        return map {"num" : xs:integer($sf/@num), "path" : $voice:audioBasePath||"/"||$filename}:)
                        
		            order by $speech_event_type, xs:integer($order) ascending
		            (:where $interactants_no ne 0:)
	    	        return
						<_ type="object">
							<id>{data($i)}</id>
							<title>{normalize-space($title)}</title>
							<domain>{$dom}</domain>
							<spet>{$speech_event_type}</spet>
							<refs type="object">
							     <audio type="{if ($audioLocation != '') then 'string' else 'null'}">{$audioLocation}</audio>
							     <TEI>{voice:path($i, "tei")}</TEI>
							     <teiHeader>{voice:path($i, "header")}</teiHeader>
							</refs>
							<audioAvailable type="boolean">{$audioLocation != ''}</audioAvailable>
							<!--type="array">{
							     for $t in $tracks
							     return 
							         <_ type="object">
							             <num type="number">{$t('num')}</num>
							             <location>{$t('path')}</location>
							         </_>
							}</tracks>-->
							<words type="number">{$no_of_words}</words>
                            <wordsBucket type="string">{$no_of_words_bucket}</wordsBucket>
							<duration type="number">{$dur_in_seconds}</duration>
                            <durationBucket type="string">{$dur_bucket}</durationBucket>
							<speakersNo type="number">{$speakers_no}</speakersNo>
							<speakersBucket type="string">{$speakers_bucket}</speakersBucket>
                            <speakersTags type="object">{for $p in $header//tei:listPerson//*[@xml:id]
                            return element {substring-after(data($p/@xml:id), '_')} {attribute {'type'} {'object'}, $voice:speakers/*/*[local-name() = substring(data($p/@sameAs), 2)]/(* except refs), <ref>{substring(data($p/@sameAs), 2)}</ref>}
                              (: $voice:speakers/*/*[refs/*/local-name() = data($i)] update delete node ./refs :)
                            }</speakersTags>
                            <speakersL1 type="array">{distinct-values($voice:speakers/*/*[refs/*/local-name() = data($i)]/L1/_/replace(.,'^([^-]+)-.*$', '$1'))[. != '']!<_>{.}</_>}</speakersL1>
							<interactantsNo type="number">{$interactants_no}</interactantsNo>
							<interactantsBucket>{$interactants_bucket}</interactantsBucket>
                            <relationPower type="string">{$relation[@type="power"]/data(@name)}</relationPower>
                            <relationAcquaintedness type="string">{$relation[@type="acquaintedness"]/data(@name)}</relationAcquaintedness>
						</_>
				}</speechEvents>
        	</_>
	    }</domains>
   </json>}
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/corpus/header")
  %rest:GET
  %rest:produces("application/xml")
  %rest:produces("text/html")
  %rest:query-param("method", "{$method}", "xhtml")
function voice:getHeader($method as xs:string?) {
    let $input := <cq:corpusHeader xml:space="preserve">{$voice:corpusHeader/tei:teiCorpus[1]/tei:teiHeader}</cq:corpusHeader>,
        $ret := switch($method)
      case 'xhtml' return (        
        <link rel="stylesheet" type="text/css" href="../voice_online.css"/>,
        <link rel="stylesheet" type="text/css" href="../view_transcript.css"/>,
        xslt:transform($input, 'styles/voice.xsl')
      )
      default return $input   
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/{$id}")
  %rest:GET
  %rest:query-param("method", "{$method}", "html")
function voice:get-doc($id, $method as xs:string?) {
  let $ret := switch ($method)
  case "html" return (
    <link rel="stylesheet" type="text/css" href="../voice_online.css"/>,
    <link rel="stylesheet" type="text/css" href="../view_transcript.css"/>,
    parse-xml-fragment(xslt:transform-text(doc($voice:collection||"/"||$id||".xml"), doc(file:parent(static-base-uri())||"/styles/voice.xsl")))
  )
  default return doc($voice:collection||"/"||$id||".xml")
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/voice_online.css")
  %rest:header-param("If-None-Match", "{$if-none-match}")
  %rest:GET
function voice:get-voice-online-css($if-none-match as xs:string?) {
  voice:return-content(file:read-binary(file:parent(static-base-uri())||'/voice_online.css'), web:content-type(file:parent(static-base-uri())||'/voice_online.css'), $if-none-match)
};

declare
  %rest:path("/VOICE_CLARIAH/view_transcript.css")
  %rest:header-param("If-None-Match", "{$if-none-match}")
  %rest:GET
function voice:get-view-transcript-css($if-none-match as xs:string?) {
  voice:return-content(file:read-binary(file:parent(static-base-uri())||'/view_transcript.css'), web:content-type(file:parent(static-base-uri())||'/view_transcript.css'), $if-none-match)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/{$id}/header")
  %rest:GET
  %output:method("xml")
function voice:get-header($id) {
    doc($voice:collection||"/"||$id||".xml")//tei:teiHeader
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/search")
  %rest:GET
  %rest:query-param("q", "{$q}")
  %rest:query-param("from", "{$from}", "1")
  %rest:query-param("pagesize", "{$pagesize}", "20")
  %rest:query-param("method", "{$method}", "html")
function voice:search($q as xs:string?, $from as xs:integer, $pagesize as xs:integer, $method as xs:string?) {
  let $log := voice:l($q),
      $response := http:send-request(
    <http:request method="GET"
     href='{$voice:noskeRunCgi}/first?corpname=voice&amp;queryselector=iqueryrow&amp;iquery={translate($q, ' ', '+')}&amp;attrs=wid&amp;kwicleftctx=0&amp;kwicrightctx=0&amp;pagesize=100000'/>
  ),
      $resultIDs := $response[2]//Lines/_/Kwic/_/str,
      $foundTags := map:merge((for $id at $i in $resultIDs
        let $foundTags := collection($voice:collection)//*[@xml:id = tokenize($id, ' ')]
        group by $uID := $foundTags/ancestor::*:u/@xml:id/data()
        return map{if (empty($uID)) then 'catch empty utterance ID' else $uID: $foundTags})), (: TODO where does this come from? search "be not":)
      $foundUtteranceIDs := subsequence(distinct-values($foundTags?*!ancestor::*:u/@xml:id), $from, $pagesize),
      $utterances := <_>{collection($voice:collection)//*[@xml:id = $foundUtteranceIDs]}</_>,
      $highlightedUtterances := <_>{for $u in $utterances/*
        let $highlightIDs := $foundTags($u/@xml:id)/@xml:id
        return $u update for $n in .//*[@xml:id = $highlightIDs] return replace node $n with <exist:match>{$n}</exist:match>}</_>,
      $ret := switch ($method)
        case "html" return (
          <link rel="stylesheet" type="text/css" href="voice_online.css"/>,
          <link rel="stylesheet" type="text/css" href="view_transcript.css"/>,
          parse-xml-fragment(xslt:transform-text($highlightedUtterances, doc(file:parent(static-base-uri())||"/styles/voice.xsl")))
        )
        case "basex" return $foundTags
        default return $highlightedUtterances
  return (<rest:response> 
    <output:serialization-parameters>
      <output:media-type value="{if ($method = ('xhtml', 'html')) then 'text/html'
                                 else if ($method='xml') then 'application/xml'
                                 else if ($method='json') then 'application/json' else 'text/plain'}"/>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret
   (: , if ($foundTags('xxx')) then (<error/>, $foundTags('xxx')) else () :)
   )
};

declare
    %rest:path('/VOICE_CLARIAH/openapi.json')
    %rest:produces('application/json')
    %output:media-type('application/json')
function voice:getOpenapiJSON() as item()+ {
  openapi:json(file:base-dir())
};

declare %private function voice:l($message as xs:string) as empty-sequence() {
  if ($voice:log) then admin:write-log($message, 'INFO') else ()
};

declare %private function voice:return-content($bin, $media-type as xs:string, $if-none-match as xs:string?) {
  let $hash := xs:string(xs:hexBinary(hash:md5($bin)))
      , $hashBrowser := if (empty($if-none-match)) then
        try {request:header('If-None-Match', '')} catch * {''} (: broken in 9.0.2 :)
        else $if-none-match
    return if ($hash = $hashBrowser) then
      voice:workaround_902(web:response-header(map{}, map{}, map{'status': 304, 'message': 'Not Modified'}))
    else (
      voice:workaround_902(web:response-header(map { 'media-type': $media-type,
                                'method': 'basex',
                                'binary': 'yes' }, 
                          map { 'X-UA-Compatible': 'IE=11'
                              , 'Cache-Control': 'max-age=3600,public'
                              , 'ETag': $hash })),
      $bin
    )
};

declare %private function voice:workaround_902($in as element(rest:response)) as element(rest:response) {
  if (db:system()//version = ('9.0.2'))
  then copy $out := $in
  modify (delete node $out/@message,
              delete node $out/@status,
              insert node $in/@message as first into $out/*:response,
              insert node $in/@status as first into $out/*:response )
  return parse-xml-fragment(serialize(<_ xmlns:rest="http://exquery.org/ns/restxq" xmlns:http="http://expath.org/ns/http-client" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">{$out}</_>, map {'indent': 'no'}))/*/*
  else $in
};
